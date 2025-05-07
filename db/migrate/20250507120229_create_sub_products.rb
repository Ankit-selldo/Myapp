class CreateSubProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :sub_products do |t|
      t.string :name
      t.decimal :price
      t.string :color
      t.string :size
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
