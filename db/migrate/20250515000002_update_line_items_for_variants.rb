class UpdateLineItemsForVariants < ActiveRecord::Migration[7.1]
  def change
    remove_index :line_items, [:cart_id, :product_id]
    remove_reference :line_items, :product
    add_reference :line_items, :product_variant, null: false, foreign_key: true
    add_index :line_items, [:cart_id, :product_variant_id], unique: true
  end
end 