class AddLatitudeLongitudeToPlaces < ActiveRecord::Migration
  def change
  	add_column :places, :latitude, :decimal, precision: 10, scale: 6, after: :admin_code3
    add_column :places, :longitude, :decimal, precision: 10, scale: 6, after: :latitude
  end
end
