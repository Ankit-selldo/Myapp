class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :number, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_address, presence: true

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

  # Enum definitions
  enum :status, STATUSES
  enum :payment_status, PAYMENT_STATUSES

  before_validation :set_default_number, on: :create
  before_validation :calculate_total_amount

  scope :completed, -> { where(status: [:shipped, :delivered]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: :pending) }
  scope :shipped, -> { where(status: :shipped) }
  scope :cancelled, -> { where(status: :cancelled) }

  def status_label
    status.to_s.humanize
  end

  def payment_status_label
    payment_status.to_s.humanize
  end

  def total_items
    order_items.sum(:quantity)
  end

  def shipped?
    status == 'shipped'
  end

  private

  def set_default_number
    return if number.present?
    
    last_number = Order.maximum(:number)
    prefix = "ORD"
    
    if last_number && last_number.start_with?(prefix)
      number_part = last_number[3..-1].to_i
      self.number = sprintf("#{prefix}%06d", number_part + 1)
    else
      self.number = "#{prefix}000001"
    end
  end

  def calculate_total_amount
    self.total_amount = order_items.sum(&:total_price)
  end
end 