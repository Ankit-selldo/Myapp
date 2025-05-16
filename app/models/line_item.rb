class LineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  has_one :product, through: :product_variant

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :variant_must_be_in_stock

  def total_price
    product_variant.final_price * quantity
  end

  private

  def variant_must_be_in_stock
    return unless product_variant && quantity

    if product_variant.inventory_count < quantity
      errors.add(:quantity, "is greater than available stock (#{product_variant.inventory_count} available)")
    end
  end
end 