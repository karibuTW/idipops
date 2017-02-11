class AddUnreadToPostCategorySubscriptions < ActiveRecord::Migration
  def change
    add_column :post_category_subscriptions, :unread, :boolean, default: false, after: :post_category_id
    add_column :post_category_subscriptions, :notified, :boolean, default: false, after: :post_category_id
    add_column :post_category_subscriptions, :last_read_at, :datetime, after: :post_category_id
  end
end
