class CreateUsersFavoritePostComment < ActiveRecord::Migration
  def change
    create_table :users_favorite_post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post_comment, index: true, foreign_key: true
      t.index [:user_id, :post_comment_id], unique: true, name: "index_users_favorite_post_comments_on_user_and_post_comment_ids"
      t.timestamps
    end
  end
end
