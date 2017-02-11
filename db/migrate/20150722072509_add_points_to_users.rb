class AddPointsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :points, :integer, null: false, default: 0, after: :newsletter
  end
end
