class CreateBlogPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :slug
      t.string :status
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
  end
end
