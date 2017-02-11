class CreatePostComments < ActiveRecord::Migration
  def change
    create_table :post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true
      t.text :content
      t.timestamps
    end
  end
end
