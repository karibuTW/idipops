class CreateClassifiedAds < ActiveRecord::Migration
  def change
    create_table :classified_ads do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.references :user, index: true
      t.references :place, index: true
      t.references :profession, index: true
    end
  end
end
