# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  password_digest :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Account < ActiveRecord::Base

  has_secure_password

	has_many :users
	has_many :account_emails

	def send_new_password
    new_password = SecureRandom.urlsafe_base64(10)
    self.update_attributes(password: new_password)
    UserMailer.new_password_request_email(self.users.first.id, new_password).deliver
  end
end
