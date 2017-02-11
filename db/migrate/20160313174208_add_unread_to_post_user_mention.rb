class AddUnreadToPostUserMention < ActiveRecord::Migration
  def change
    add_column :post_user_mentions, :unread, :boolean, default: false, after: :post_id
    add_column :post_user_mentions, :notified, :boolean, default: false, after: :post_id
    add_column :post_user_mentions, :last_read_at, :boolean, after: :post_id
  end
end
