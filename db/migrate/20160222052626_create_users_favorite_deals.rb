class CreateUsersFavoriteDeals < ActiveRecord::Migration
  def change
    create_table :users_favorite_deals do |t|
      t.references :user, index: true, foreign_key: true
      t.references :deal, index: true, foreign_key: true
      t.index [:user_id, :deal_id], unique: true
      t.timestamps
    end
    add_column :deals, :users_favorite_deals_count, :integer, default: 0, after: :list_image_uid
  end
end
