# == Schema Information
#
# Table name: classified_ad_photos
#
#  id               :integer          not null, primary key
#  attachment_uid   :string(255)
#  user_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class UserPhoto < ActiveRecord::Base
	dragonfly_accessor :attachment
	belongs_to :user
end
