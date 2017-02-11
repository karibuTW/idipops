class CreatePriceForCategories < ActiveRecord::Migration
  def change
    create_table :price_for_categories do |t|
      t.integer :credit_amount
      t.money :amount
      t.references :pricing_category, index: true
      t.references :pricing, index: true
      t.timestamps
    end
    remove_column :pricings, :pricing_category_id, :integer, :index
    remove_column :pricings, :credit_amount, :integer
    remove_column :pricings, :amount_cents, :integer
    remove_column :pricings, :amount_currency, :string
  end
end
