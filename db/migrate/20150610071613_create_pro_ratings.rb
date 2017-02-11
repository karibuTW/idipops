class CreateProRatings < ActiveRecord::Migration
  def change
    create_table :pro_ratings do |t|
      t.integer :rating
      t.integer :user_id
      t.integer :pro_id
      t.index [:user_id, :pro_id], unique: true
      t.timestamps
    end
  end
end
