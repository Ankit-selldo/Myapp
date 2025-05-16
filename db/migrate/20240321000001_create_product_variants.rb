class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size
      t.string :color
      t.integer :inventory_count, default: 0
      t.decimal :price_adjustment, precision: 10, scale: 2, default: 0
      t.string :sku
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :product_variants, [:product_id, :size, :color], unique: true
    add_index :product_variants, :sku, unique: true
  end
end 