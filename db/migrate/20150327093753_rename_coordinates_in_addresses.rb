class RenameCoordinatesInAddresses < ActiveRecord::Migration
  def change
  	change_table :addresses do |t|
	  t.rename :lat, :latitude
	  t.rename :lng, :longitude
	end
  end
end
