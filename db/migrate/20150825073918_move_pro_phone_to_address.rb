class MoveProPhoneToAddress < ActiveRecord::Migration
  def change
  	User.pro.find_each do |user|
  		address = user.addresses[0]
  		address.update(land_phone: user.land_phone, mobile_phone: user.mobile_phone) if address
  	end
  end
end
