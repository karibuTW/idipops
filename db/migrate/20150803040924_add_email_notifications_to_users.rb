class AddEmailNotificationsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :email_notifications, :boolean, after: :newsletter, default: true
  end
end
