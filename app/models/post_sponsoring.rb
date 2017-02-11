# == Schema Information
#
# Table name: profile_sponsorings
#
#  id                    :integer          not null, primary key
#  credit_transaction_id :integer
#  post_id               :integer
#  initial_impressions   :integer          default(0)
#  remaining_impressions :integer          default(0)
#  display_location      :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class PostSponsoring < ActiveRecord::Base

	belongs_to :post
	belongs_to :credit_transaction
	
end
