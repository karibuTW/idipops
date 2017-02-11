class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :description
      t.references :user, index: true
      t.money :amount
      t.money :balance

      t.timestamps
    end
  end
end