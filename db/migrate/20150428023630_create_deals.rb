class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :tagline
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.references :user, index: true
      t.string :featured_image_uid
      t.string :list_image_uid
      t.timestamps
    end
  end
end
