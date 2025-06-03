class Order < ApplicationRecord
  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :shipping_name, presence: true
  validates :shipping_address, presence: true
  validates :shipping_city, presence: true
  validates :shipping_state, presence: true
  validates :shipping_postal_code, presence: true
  validates :shipping_country, presence: true
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/ }
  validates :payment_method, presence: true, inclusion: { in: %w[cod online] }, on: :payment
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :number, uniqueness: true, allow_nil: true

  # Define status values
  STATUSES = {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }.freeze

  PAYMENT_STATUSES = {
    pending_payment: 0,
    paid: 1,
    refunded: 2,
    failed: 3
  }.freeze

  PAYMENT_METHODS = {
    'cod' => 'Cash on Delivery',
    'online' => 'Online Payment'
  }.freeze

  # Enum definitions
  enum :status, STATUSES
  enum :payment_status, PAYMENT_STATUSES

  before_validation :set_default_number, on: :create
  before_validation :calculate_total_amount
  before_validation :set_default_payment_method
  before_save :ensure_order_items_present, if: :will_save_change_to_status?
  after_save :increment_coupon_usage, if: :coupon_id_previously_changed?
  after_save :update_inventory, if: :saved_change_to_status?

  scope :completed, -> { where(status: [:shipped, :delivered]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: :pending) }
  scope :processing, -> { where(status: :processing) }
  scope :shipped, -> { where(status: :shipped) }
  scope :delivered, -> { where(status: :delivered) }
  scope :cancelled, -> { where(status: :cancelled) }

  def status_label
    status.to_s.humanize
  end

  def payment_status_label
    payment_status.to_s.humanize
  end

  def payment_method_label
    PAYMENT_METHODS[payment_method] || payment_method&.titleize
  end

  def total_items
    order_items.sum(:quantity)
  end

  def subtotal
    order_items.sum(&:total_price)
  end

  def total_amount
    calculated_total = subtotal + cod_fee.to_d - discount_amount.to_d
    calculated_total.negative? ? 0 : calculated_total
  end

  def cod_fee
    payment_method == 'cod' ? 50 : 0
  end

  def apply_coupon(code)
    coupon = Coupon.find_by(code: code&.upcase)
    return false unless coupon&.valid_for_order?(subtotal)

    self.coupon = coupon
    self.discount_amount = coupon.calculate_discount(subtotal)
    save
  end

  def shipped?
    status == 'shipped'
  end

  def build_from_cart(cart)
    return if cart.nil? || cart.line_items.empty?

    cart.line_items.each do |item|
      variant = item.product_variant
      order_items.build(
        product: variant.product,
        product_variant: variant,
        quantity: item.quantity,
        price: variant.final_price,
        total_price: item.total_price
      )
    end
  end

  def create_payment_intent
    begin
      # Create a PaymentIntent with the order amount and currency
      payment_intent = Stripe::PaymentIntent.create(
        amount: (total_amount * 100).to_i, # Convert to cents
        currency: 'inr',
        metadata: {
          order_id: id
        }
      )
      payment_intent
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe Error: #{e.message}"
      nil
    end
  end

  private

  def set_default_number
    return if number.present?
    self.number = loop do
      random = "ORD#{Time.current.strftime('%y%m%d')}#{rand(1000..9999)}"
      break random unless Order.exists?(number: random)
    end
  end

  def calculate_total_amount
    self.total_amount = total_amount
  end

  def set_default_payment_method
    self.payment_method ||= 'online'
  end

  def ensure_order_items_present
    return true unless status_changed? && (processing? || shipped? || delivered?)
    errors.add(:base, "Order must have at least one item") if order_items.empty?
  end

  def increment_coupon_usage
    coupon&.increment_usage! if saved_change_to_coupon_id?
  end

  def update_inventory
    return unless status_changed?

    case status
    when 'processing'
      # Deduct inventory when order is being processed
      order_items.each do |item|
        variant = item.product_variant
        variant.decrement!(:inventory_count, item.quantity)
      end
    when 'cancelled'
      # Return inventory when order is cancelled
      order_items.each do |item|
        variant = item.product_variant
        variant.increment!(:inventory_count, item.quantity)
      end
    end
  end
end 