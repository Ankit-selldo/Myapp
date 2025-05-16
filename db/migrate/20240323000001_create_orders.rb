class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :number, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0
      t.integer :status, default: 0, null: false
      t.integer :payment_status, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.text :shipping_address
      t.string :tracking_number

      t.timestamps
    end

    add_index :orders, :number, unique: true
    add_index :orders, :status
    add_index :orders, :payment_status
    add_index :orders, :created_at
  end
end 