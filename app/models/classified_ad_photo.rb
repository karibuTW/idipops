# == Schema Information
#
# Table name: classified_ad_photos
#
#  id               :integer          not null, primary key
#  attachment_uid   :string(255)
#  classified_ad_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class ClassifiedAdPhoto < ActiveRecord::Base
	dragonfly_accessor :attachment
	belongs_to :classified_ad
end
