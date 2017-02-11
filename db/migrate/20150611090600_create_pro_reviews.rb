class CreateProReviews < ActiveRecord::Migration
  def change
    create_table :pro_reviews do |t|
      t.string :content
      t.integer :user_id
      t.integer :pro_id
      t.index :user_id
      t.index :pro_id
      t.index [:user_id, :pro_id], unique: true
      t.timestamps
    end
  end
end
