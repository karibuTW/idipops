class CreatePricingCategories < ActiveRecord::Migration
  def change
    create_table :pricing_categories do |t|
      t.string :name
      t.timestamps
    end
  end
end
