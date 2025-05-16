class EnhanceBlogPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :blog_posts, :category, :string
    add_column :blog_posts, :reading_time, :integer
    add_column :blog_posts, :featured, :boolean, default: false
    add_column :blog_posts, :meta_title, :string
    add_column :blog_posts, :meta_description, :text
    add_column :blog_posts, :related_product_ids, :integer, array: true, default: []
    
    add_index :blog_posts, :category
    add_index :blog_posts, :featured
  end
end 