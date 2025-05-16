class UpdateOrderStatusColumns < ActiveRecord::Migration[7.1]
  def up
    # Temporarily rename existing columns
    rename_column :orders, :status, :old_status
    rename_column :orders, :payment_status, :old_payment_status

    # Add new integer columns
    add_column :orders, :status, :integer, default: 0, null: false
    add_column :orders, :payment_status, :integer, default: 0, null: false

    # Update the data
    execute <<-SQL
      UPDATE orders 
      SET status = CASE old_status
        WHEN 'pending' THEN 0
        WHEN 'processing' THEN 1
        WHEN 'shipped' THEN 2
        WHEN 'delivered' THEN 3
        WHEN 'cancelled' THEN 4
        ELSE 0
      END,
      payment_status = CASE old_payment_status
        WHEN 'pending' THEN 0
        WHEN 'paid' THEN 1
        WHEN 'refunded' THEN 2
        WHEN 'failed' THEN 3
        ELSE 0
      END
    SQL

    # Remove old columns
    remove_column :orders, :old_status
    remove_column :orders, :old_payment_status

    # Add indexes
    add_index :orders, :status
    add_index :orders, :payment_status
  end

  def down
    # Temporarily rename existing columns
    rename_column :orders, :status, :new_status
    rename_column :orders, :payment_status, :new_payment_status

    # Add string columns
    add_column :orders, :status, :string, default: 'pending', null: false
    add_column :orders, :payment_status, :string, default: 'pending', null: false

    # Update the data
    execute <<-SQL
      UPDATE orders 
      SET status = CASE new_status
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        WHEN 4 THEN 'cancelled'
        ELSE 'pending'
      END,
      payment_status = CASE new_payment_status
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'refunded'
        WHEN 3 THEN 'failed'
        ELSE 'pending'
      END
    SQL

    # Remove temporary columns
    remove_column :orders, :new_status
    remove_column :orders, :new_payment_status

    # Add indexes
    add_index :orders, :status
    add_index :orders, :payment_status
  end
end 