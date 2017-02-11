class AddDetailedNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, after: :name
    add_column :users, :last_name, :string, after: :first_name
    add_column :users, :name_is_public, :boolean, default: true, after: :last_name
    rename_column :users, :name, :company_name
  end
end
