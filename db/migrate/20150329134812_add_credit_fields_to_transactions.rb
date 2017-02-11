class AddCreditFieldsToTransactions < ActiveRecord::Migration
  def change
  	remove_money :transactions, :balance
    add_column :transactions, :credit_balance, :int, after: :amount_currency
    add_column :transactions, :credit_amount, :int, after: :credit_balance
  end
end
