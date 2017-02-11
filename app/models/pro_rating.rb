# == Schema Information
#
# Table name: pro_ratings
#
#  id         :integer          not null, primary key
#  rating     :integer
#  user_id    :integer
#  pro_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class ProRating < ActiveRecord::Base
	belongs_to :user
	belongs_to :professional, class_name: "User", foreign_key: "pro_id"
end
