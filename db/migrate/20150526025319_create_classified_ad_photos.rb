class CreateClassifiedAdPhotos < ActiveRecord::Migration
  def change
    create_table :classified_ad_photos do |t|
      t.string :attachment_uid
      t.references :classified_ad, index: true
      t.timestamps
    end
  end
end
