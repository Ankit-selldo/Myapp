class EnsureUserFields < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :name unless column_exists?(:users, :name)
      t.string :role unless column_exists?(:users, :role)
      t.string :verification_token unless column_exists?(:users, :verification_token)
      t.datetime :email_verified_at unless column_exists?(:users, :email_verified_at)
    end

    # Add indexes
    add_index :users, :role unless index_exists?(:users, :role)
    add_index :users, :verification_token, unique: true unless index_exists?(:users, :verification_token)
  end
end 