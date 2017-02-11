class AddBirthdateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birthdate, :date, after: :user_type
  end
end
