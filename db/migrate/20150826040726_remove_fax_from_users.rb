class RemoveFaxFromUsers < ActiveRecord::Migration
  def change
  	User.pro.find_each do |user|
  		address = user.addresses[0]
  		address.update(fax: user.fax) if address
  	end
    remove_column :users, :fax, :string
  end
end
