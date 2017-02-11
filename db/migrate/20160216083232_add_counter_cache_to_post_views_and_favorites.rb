class AddCounterCacheToPostViewsAndFavorites < ActiveRecord::Migration
  def change
    add_column :posts, :post_views_count, :integer, default: 0, after: :reporter_id
    add_column :posts, :users_favorite_posts_count, :integer, default: 0, after: :reporter_id
  end
end
