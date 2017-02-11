class AddSiretAdvantagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :siret, :string, after: :website
    add_column :users, :advantages, :text, after: :references
  end
end
