class CreateProfessions < ActiveRecord::Migration
  def change
    create_table :professions do |t|
      t.string :name
      t.text :description
      t.boolean :active
      t.string :ancestry
      t.index :ancestry

      t.timestamps
    end
  end
end
