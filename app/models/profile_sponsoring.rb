# == Schema Information
#
# Table name: profile_sponsorings
#
#  id                    :integer          not null, primary key
#  credit_transaction_id :integer
#  user_id               :integer
#  initial_impressions   :integer          default(0)
#  remaining_impressions :integer          default(0)
#  display_location      :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class ProfileSponsoring < ActiveRecord::Base

	belongs_to :user
	belongs_to :credit_transaction
	
end
