class CreateProfessionsAndPostCategories < ActiveRecord::Migration
  def change
    create_table :post_categories_professions do |t|
      t.references :profession, index: true, foreign_key: true
      t.references :post_category, index: true, foreign_key: true
    end
  end
end
