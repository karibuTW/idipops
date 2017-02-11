class CreatePostCategorySubscription < ActiveRecord::Migration
  def change
    create_table :post_category_subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :post_category, index: true, foreign_key: true
      t.timestamps
    end
  end
end
