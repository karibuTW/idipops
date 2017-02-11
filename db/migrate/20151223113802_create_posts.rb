class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :type
      t.text :description
      t.string :featured_image_uid
      t.references :user, index: true
      t.timestamps
    end
  end
end
