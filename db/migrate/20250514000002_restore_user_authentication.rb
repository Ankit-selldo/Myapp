class RestoreUserAuthentication < ActiveRecord::Migration[8.0]
  def change
    # Remove Devise columns
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :email

    # Add back has_secure_password column if not exists
    add_column :users, :password_digest, :string unless column_exists?(:users, :password_digest)
    
    # Add back custom authentication columns if not exist
    add_column :users, :password_reset_token, :string unless column_exists?(:users, :password_reset_token)
    add_column :users, :password_reset_sent_at, :datetime unless column_exists?(:users, :password_reset_sent_at)
  end
end 