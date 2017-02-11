class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :country_code
      t.string :postal_code
      t.string :place_name
      t.string :admin_name1
      t.string :admin_code1
      t.string :admin_name2
      t.string :admin_code2
      t.string :admin_name3
      t.string :admin_code3
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :accuracy
    end
  end
end
