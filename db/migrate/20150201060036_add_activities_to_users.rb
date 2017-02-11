class AddActivitiesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :primary_activity_id, :integer, index: true
    add_column :users, :secondary_activity_id, :integer, index: true
  end
end
