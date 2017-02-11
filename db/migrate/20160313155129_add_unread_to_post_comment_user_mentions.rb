class AddUnreadToPostCommentUserMentions < ActiveRecord::Migration
  def change
    add_column :post_comment_user_mentions, :unread, :boolean, default: false, after: :post_comment_id
    add_column :post_comment_user_mentions, :notified, :boolean, default: false, after: :post_comment_id
    add_column :post_comment_user_mentions, :last_read_at, :datetime, after: :post_comment_id
  end
end
