class FixUserRoleColumn < ActiveRecord::Migration[8.0]
  def up
    # Remove the old column and create a new one
    remove_column :users, :role
    add_column :users, :role, :integer, default: 0
    add_index :users, :role
  end

  def down
    change_column :users, :role, :string, default: 'customer'
  end
end 