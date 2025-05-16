class FixDeviseEmailFields < ActiveRecord::Migration[7.1]
  def up
    # Remove Devise's email column if it exists
    remove_column :users, :email if column_exists?(:users, :email)
    
    # Ensure email_address column exists and has the correct properties
    unless column_exists?(:users, :email_address)
      add_column :users, :email_address, :string, null: false
      add_index :users, :email_address, unique: true
    end

    # Update other Devise-related columns
    unless column_exists?(:users, :encrypted_password)
      add_column :users, :encrypted_password, :string, null: false, default: ""
    end
  end

  def down
    # This is a safety migration, no rollback needed
    raise ActiveRecord::IrreversibleMigration
  end
end 