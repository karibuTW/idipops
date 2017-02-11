class AddPlaceRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :place, index: true
  end
end
