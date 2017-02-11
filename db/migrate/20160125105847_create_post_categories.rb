class CreatePostCategories < ActiveRecord::Migration
  def change
    create_table :post_categories do |t|
      t.string :name
      t.boolean :active
      t.string :ancestry
      t.integer :ancestry_depth, default: 0
      t.timestamps
    end
  end
end
