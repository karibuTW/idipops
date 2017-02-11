class CreatePostUserMentions < ActiveRecord::Migration
  def change
    create_table :post_user_mentions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true
      t.index [:user_id, :post_id], unique: true
      t.timestamps
    end
  end
end
