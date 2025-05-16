class AddFeaturedToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :featured, :boolean, default: false
    add_index :products, :featured
  end
end 