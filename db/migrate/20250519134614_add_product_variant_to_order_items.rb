class AddProductVariantToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_items, :product_variant, null: false, foreign_key: true
  end
end