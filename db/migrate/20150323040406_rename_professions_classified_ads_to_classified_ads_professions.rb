class RenameProfessionsClassifiedAdsToClassifiedAdsProfessions < ActiveRecord::Migration
  def self.up
    rename_table :professions_classified_ads, :classified_ads_professions
  end

 def self.down
    rename_table :classified_ads_professions, :professions_classified_ads
 end
end
