class CreateProfileViews < ActiveRecord::Migration
  def change
    create_table :profile_views do |t|
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :user, index: true
      t.timestamps
    end
  end
end
