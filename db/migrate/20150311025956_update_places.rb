class UpdatePlaces < ActiveRecord::Migration
  def change
  	remove_column :places, :admin_name3
  	remove_column :places, :latitude
  	remove_column :places, :longitude
  	remove_column :places, :accuracy
  	add_column :places, :geo_point_2d, :string, after: :admin_code3
  	add_column :places, :geo_shape, :text, after: :geo_point_2d
  end
end
