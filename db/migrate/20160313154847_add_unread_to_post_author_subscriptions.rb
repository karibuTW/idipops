class AddUnreadToPostAuthorSubscriptions < ActiveRecord::Migration
  def change
    add_column :post_author_subscriptions, :unread, :boolean, default: false, after: :author_id
    add_column :post_author_subscriptions, :notified, :boolean, default: false, after: :author_id
    add_column :post_author_subscriptions, :last_read_at, :datetime, after: :author_id
  end
end
