# == Schema Information
#
# Table name: post_photos
#
#  id               :integer          not null, primary key
#  attachment_uid   :string(255)
#  post_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class PostPhoto < ActiveRecord::Base
	dragonfly_accessor :attachment
	belongs_to :post
end
