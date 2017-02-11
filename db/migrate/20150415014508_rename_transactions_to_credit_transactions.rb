class RenameTransactionsToCreditTransactions < ActiveRecord::Migration
  def change
  	rename_table :transactions, :credit_transactions

  	change_table :authorizations do |t|
	  t.rename :transaction_id, :credit_transaction_id
	end
  end
end
