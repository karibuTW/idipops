class MoveUserRefBeforeDate < ActiveRecord::Migration
  def change
  	change_column :users, :place_id, :int, after: :avatar_uid
  	change_column :users, :secondary_activity_id, :int, after: :avatar_uid
  	change_column :users, :primary_activity_id, :int, after: :avatar_uid
  end
end
