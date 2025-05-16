class CreateDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :discounts do |t|
      t.string :code, null: false
      t.text :description
      t.string :discount_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :minimum_purchase, precision: 10, scale: 2
      t.datetime :starts_at, null: false
      t.datetime :expires_at, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :discounts, :code, unique: true
    add_index :discounts, :active
    add_index :discounts, :starts_at
    add_index :discounts, :expires_at

    create_table :discounts_products, id: false do |t|
      t.references :discount, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
    end

    add_index :discounts_products, [:discount_id, :product_id], unique: true
  end
end 