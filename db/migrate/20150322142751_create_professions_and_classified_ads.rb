class CreateProfessionsAndClassifiedAds < ActiveRecord::Migration
  def change
    create_table :professions_classified_ads do |t|
    	t.belongs_to :profession, index: true
      t.belongs_to :classified_ad, index: true
    end
    remove_column :classified_ads, :profession_id
  end
end
