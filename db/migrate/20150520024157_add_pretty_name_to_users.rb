class AddPrettyNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pretty_name, :string, index: true, unique: true, after: :company_name
  end
end
