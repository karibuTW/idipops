class RemoveCreditBalanceFromCreditTransactions < ActiveRecord::Migration
  def change
    remove_column :credit_transactions, :credit_balance, :int
  end
end
