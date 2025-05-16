class EnsureDeviseColumns < ActiveRecord::Migration[7.1]
  def change
    # Add encrypted_password if it doesn't exist
    unless column_exists?(:users, :encrypted_password)
      add_column :users, :encrypted_password, :string, null: false, default: ""
    end

    # Add reset password fields if they don't exist
    unless column_exists?(:users, :reset_password_token)
      add_column :users, :reset_password_token, :string
      add_column :users, :reset_password_sent_at, :datetime
      add_index :users, :reset_password_token, unique: true
    end

    # Add remember token if it doesn't exist
    unless column_exists?(:users, :remember_created_at)
      add_column :users, :remember_created_at, :datetime
    end

    # Remove password_digest if it exists (since we're using Devise's encrypted_password)
    if column_exists?(:users, :password_digest)
      remove_column :users, :password_digest
    end
  end
end 