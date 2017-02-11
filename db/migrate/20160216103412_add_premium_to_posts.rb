class AddPremiumToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :premium, :boolean, default: false, after: :post_views_count
  end
end
