class CreatePricing < ActiveRecord::Migration
  def change
    create_table :pricings do |t|
      t.string :target
      t.integer :credit_amount
      t.money :amount
      t.datetime :start_date
      t.timestamps
    end
  end
end
