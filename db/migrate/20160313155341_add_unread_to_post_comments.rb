class AddUnreadToPostComments < ActiveRecord::Migration
  def change
    add_column :post_comments, :unread, :boolean, default: false, after: :content
    add_column :post_comments, :notified, :boolean, default: false, after: :content
    add_column :post_comments, :last_read_at, :datetime, after: :content
  end
end
