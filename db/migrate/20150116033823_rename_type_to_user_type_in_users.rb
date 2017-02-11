class RenameTypeToUserTypeInUsers < ActiveRecord::Migration
  def change
  	change_table :users do |t|
	  t.rename :type, :user_type
	end
  end
end
