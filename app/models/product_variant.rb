class ProductVariant < ApplicationRecord
  belongs_to :product
  has_one_attached :image
  has_many :line_items
  has_many :order_items
  has_many :carts, through: :line_items
  has_many :orders, through: :order_items

  validates :size, presence: true
  validates :color, presence: true
  validates :inventory_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :price_adjustment, presence: true, numericality: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :generate_sku, on: :create  #Stock Keeping Unit
  before_save :update_product_inventory
  before_save :set_price_from_product

  def final_price
    if discount_price.present? && discount_price < price
      discount_price
    else
      price
    end
  end

  def formatted_final_price
    ActionController::Base.helpers.number_to_currency(final_price, unit: "₹", precision: 2)
  end

  def available_stock
    inventory_count
  end

  def in_stock?
    available_stock.positive?
  end

  def can_add_to_cart?(requested_quantity, cart)
    # Get current quantity in cart for this variant
    current_cart_quantity = cart.line_items.where(product_variant: self).sum(:quantity)
    
    # If decreasing quantity, allow it (including to 0)
    return true if requested_quantity < current_cart_quantity
    
    # For increasing quantity, check against inventory
    requested_quantity <= inventory_count
  end

  private

  def generate_sku
    return if sku.present?
    
    base = product.name.parameterize[0..3].upcase
    self.sku = loop do
      random_sku = "#{base}-#{size}-#{color[0..2].upcase}-#{SecureRandom.hex(2).upcase}"
      break random_sku unless ProductVariant.exists?(sku: random_sku)
    end
  end

  def update_product_inventory
    if saved_change_to_inventory_count?
      product.update_column(:inventory_count, product.product_variants.sum(:inventory_count))
    end
  end

  def set_price_from_product
    self.price = product.price + price_adjustment if product && price_adjustment.present?
  end
end 