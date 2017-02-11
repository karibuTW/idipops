class AddTokenToExistUser < ActiveRecord::Migration
  def change
  	User.find_each do |user|
  		user.token = loop do
	      random_token = SecureRandom.urlsafe_base64(nil, false)
	      break random_token unless User.exists?(token: random_token)
	    end
	    user.save
  	end
  end
end
