# == Schema Information
#
# Table name: account_emails
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  account_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class AccountEmail < ActiveRecord::Base
	belongs_to :account
	
	validates :email, presence: true, uniqueness: true, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }

	before_validation :downcase_email

	private

	def downcase_email
		self.email = self.email.downcase.strip if self.email.present?
	end
end
