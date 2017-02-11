class ChangeImpressionsForDeals < ActiveRecord::Migration
  def change
  	remove_column :deals, :impressions, :integer
    add_column :deal_promotions, :initial_impressions, :integer, after: :display_location, default: 0
    add_column :deal_promotions, :remaining_impressions, :integer, after: :initial_impressions, default: 0
  end
end
