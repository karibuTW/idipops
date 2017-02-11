class CreateAccountEmails < ActiveRecord::Migration
  def change
    create_table :account_emails do |t|
      t.string :email
      t.references :account, index: true
      t.timestamps
    end
  end
end
