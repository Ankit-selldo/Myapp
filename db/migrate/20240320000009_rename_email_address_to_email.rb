class RenameEmailAddressToEmail < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :email_address, :email
  end
end 