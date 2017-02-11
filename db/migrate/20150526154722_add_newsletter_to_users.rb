class AddNewsletterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newsletter, :boolean, after: :online, default: false
  end
end
