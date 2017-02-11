class AddPasswordDigestToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :password_digest, :string, after: :id
  end
end
