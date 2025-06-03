class AddPriceToProductVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :product_variants, :price, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end 