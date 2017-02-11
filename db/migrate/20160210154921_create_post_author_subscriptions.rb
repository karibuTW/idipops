class CreatePostAuthorSubscriptions < ActiveRecord::Migration
  def change
    create_table :post_author_subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :author_id, index: true
      t.index [:user_id, :author_id], unique: true
      t.timestamps
    end
  end
end
