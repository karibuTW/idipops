class AddSeveralTransactionsToDealPromotions < ActiveRecord::Migration
  def change
  	remove_reference :deal_promotions, :credit_transaction, index: true

  	create_table :deal_promotions_transactions, id: false do |t|
      t.belongs_to :deal_promotion, index: true
      t.belongs_to :credit_transaction, index: true
    end
  end
end
