class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :description
      t.decimal :discount_amount, precision: 10, scale: 2
      t.decimal :minimum_order_amount, precision: 10, scale: 2
      t.integer :discount_type, default: 0  # 0: fixed amount, 1: percentage
      t.integer :usage_limit
      t.integer :used_count, default: 0
      t.datetime :starts_at
      t.datetime :expires_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end 