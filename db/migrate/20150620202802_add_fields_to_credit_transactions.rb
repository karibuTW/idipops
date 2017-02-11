class AddFieldsToCreditTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :ext_transaction_id, :string, after: :credit_amount
    add_column :credit_transactions, :workflow_state, :string, after: :ext_transaction_id
  end
end
