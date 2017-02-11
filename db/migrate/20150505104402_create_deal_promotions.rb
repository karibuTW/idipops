class CreateDealPromotions < ActiveRecord::Migration
  def change
    create_table :deal_promotions do |t|
      t.references :credit_transaction, index: true
      t.references :deal, index: true
      t.integer :impressions, default: 0
      t.string :display_location
      t.timestamps
    end
  end
end
