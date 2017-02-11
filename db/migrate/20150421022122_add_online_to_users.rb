class AddOnlineToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :online, :boolean, after: :place_id, default: false
  end
end
