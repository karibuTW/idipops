class MoveImpressions < ActiveRecord::Migration
  def change
  	add_column :deals, :impressions, :integer, after: :list_image_uid, default: 0
    remove_column :deal_promotions, :impressions, :integer, default: 0
  end
end
