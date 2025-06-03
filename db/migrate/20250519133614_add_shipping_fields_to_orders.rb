class AddShippingFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :shipping_name, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_state, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_country, :string
    add_column :orders, :phone, :string
    add_column :orders, :email, :string
  end
end 