class CreatePostCommentUserMentions < ActiveRecord::Migration
  def change
    create_table :post_comment_user_mentions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post_comment, index: true, foreign_key: true
      t.index [:user_id, :post_comment_id], unique: true
      t.timestamps
    end
  end
end
