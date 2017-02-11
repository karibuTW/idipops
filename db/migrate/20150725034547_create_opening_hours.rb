class CreateOpeningHours < ActiveRecord::Migration
  def change
    create_table :opening_hours do |t|
      t.belongs_to :address
      t.integer :day, nullable: false
      t.text :periods
      t.timestamps
      t.index :address_id
    end
  end
end
