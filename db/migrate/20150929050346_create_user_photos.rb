class CreateUserPhotos < ActiveRecord::Migration
  def change
    create_table :user_photos do |t|
      t.string :attachment_uid
      t.integer :user_id
      t.timestamps
    end
  end
end
