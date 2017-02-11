class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :type
      t.string :website
      t.boolean :active, default: true
      t.boolean :admin, default: false
      t.datetime :first_login
      t.datetime :last_login
      t.text :short_description
      t.text :long_description
      t.text :references
      t.string :address
      t.string :land_phone
      t.string :mobile_phone

      t.timestamps
    end
  end
end
