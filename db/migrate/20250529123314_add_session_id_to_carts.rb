class AddSessionIdToCarts < ActiveRecord::Migration[8.0]
  def change
    add_column :carts, :session_id, :string
  end
end
