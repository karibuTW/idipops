class AddAvatarToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_uid, :string, after: :mobile_phone
  end
end
