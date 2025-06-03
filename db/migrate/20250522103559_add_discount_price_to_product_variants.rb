class AddDiscountPriceToProductVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :product_variants, :discount_price, :decimal, precision: 10, scale: 2, null: true
  end
end
