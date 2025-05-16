class AddAdditionalFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:products, :status)
      add_column :products, :status, :string, default: 'draft'
      add_index :products, :status
    end

    unless column_exists?(:products, :meta_title)
      add_column :products, :meta_title, :string
    end

    unless column_exists?(:products, :meta_description)
      add_column :products, :meta_description, :text
    end

    unless column_exists?(:products, :slug)
      add_column :products, :slug, :string
      add_index :products, :slug, unique: true
    end

    unless column_exists?(:products, :featured)
      add_column :products, :featured, :boolean, default: false
      add_index :products, :featured
    end

    unless column_exists?(:products, :inventory_count)
      add_column :products, :inventory_count, :integer, default: 0
    end
  end
end 