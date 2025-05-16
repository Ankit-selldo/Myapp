class AddPriceAndCategoryToProducts < ActiveRecord::Migration[7.1]
  def up
    # Add price column if it doesn't exist
    unless column_exists?(:products, :price)
      add_column :products, :price, :decimal, precision: 10, scale: 2, default: 0
    end

    # Add category column if it doesn't exist
    unless column_exists?(:products, :category)
      add_column :products, :category, :string
      add_index :products, :category
    end

    # Add user reference if it doesn't exist
    unless column_exists?(:products, :user_id)
      # First add the column as nullable
      add_reference :products, :user, foreign_key: true, null: true

      # Create default admin user if not exists
      admin = User.find_or_create_by!(email_address: 'admin@example.com') do |user|
        user.name = 'Admin'
        user.password = SecureRandom.hex(10)
        user.role = 'admin'
      end

      # Update existing products to belong to admin
      execute <<-SQL
        UPDATE products SET user_id = #{admin.id} WHERE user_id IS NULL;
      SQL

      # Now make it non-nullable
      change_column_null :products, :user_id, false
    end
  end

  def down
    remove_reference :products, :user if column_exists?(:products, :user_id)
    remove_column :products, :category if column_exists?(:products, :category)
    remove_column :products, :price if column_exists?(:products, :price)
  end
end 