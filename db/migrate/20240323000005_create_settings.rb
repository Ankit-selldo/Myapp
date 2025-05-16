class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:settings)
      create_table :settings do |t|
        t.string :key, null: false
        t.text :value
        t.string :category
        t.string :data_type, default: 'string'
        t.boolean :is_private, default: false

        t.timestamps
      end

      add_index :settings, :key, unique: true
      add_index :settings, :category
    end
  end
end 