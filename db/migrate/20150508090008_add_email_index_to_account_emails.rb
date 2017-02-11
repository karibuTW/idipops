class AddEmailIndexToAccountEmails < ActiveRecord::Migration
  def change
  	add_index :account_emails, :email, unique: true
  end
end
