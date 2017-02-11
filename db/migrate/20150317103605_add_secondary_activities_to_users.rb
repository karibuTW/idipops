class AddSecondaryActivitiesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fax, :string, after: :mobile_phone
    add_column :users, :tertiary_activity_id, :integer, index: true, after: :secondary_activity_id
    add_column :users, :quaternary_activity_id, :integer, index: true, after: :tertiary_activity_id
  end
end
