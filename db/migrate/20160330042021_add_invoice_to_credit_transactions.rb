class AddInvoiceToCreditTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :invoice_uid, :string, after: :workflow_state
  end
end
