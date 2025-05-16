class AddVerificationFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verification_token, :string
    add_index :users, :verification_token
    add_column :users, :email_verified_at, :datetime
  end
end
