class LinkUsersToAccounts < ActiveRecord::Migration
  def change
  	add_reference :users, :account, index: true, after: :id
  	remove_column :users, :email, :string
  end
end
