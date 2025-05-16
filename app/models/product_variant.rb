class ProductVariant < ApplicationRecord
  belongs_to :product
  has_one_attached :image

  validates :size, presence: true
  validates :color, presence: true
  validates :inventory_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :price_adjustment, presence: true, numericality: true

  before_validation :generate_sku, on: :create

  def final_price
    product.price + price_adjustment
  end

  def formatted_final_price
    ActionController::Base.helpers.number_to_currency(final_price, unit: "₹", precision: 2)
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
end 