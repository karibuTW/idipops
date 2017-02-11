class AddPremiumPostsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :premium_posts, :boolean, default: false, after: :rating
  end
end
