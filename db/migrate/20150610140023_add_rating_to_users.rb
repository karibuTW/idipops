class AddRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rating, :integer, after: :newsletter, default: 0
  end
end
