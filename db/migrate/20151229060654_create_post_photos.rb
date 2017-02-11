class CreatePostPhotos < ActiveRecord::Migration
  def change
    create_table :post_photos do |t|
      t.string :attachment_uid
      t.references :post, index: true, foreign_key: true
      t.timestamps
    end
  end
end
