class AddTimestampsToClassifiedAds < ActiveRecord::Migration
  def change
  	add_column :classified_ads, :created_at, :datetime
	add_column :classified_ads, :updated_at, :datetime
  end
end
