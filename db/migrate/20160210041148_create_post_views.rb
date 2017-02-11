class CreatePostViews < ActiveRecord::Migration
  def change
    create_table :post_views do |t|
      t.references :post, index: true, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.timestamps
    end
  end
end
