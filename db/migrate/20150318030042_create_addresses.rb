class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
    	t.belongs_to :user, index:true
      t.text :formatted_address
      t.string :place_id
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.integer :action_range, default: 50

      t.timestamps
    end
  end
end
