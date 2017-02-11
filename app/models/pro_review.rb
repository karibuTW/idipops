# == Schema Information
#
# Table name: pro_reviews
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  pro_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class ProReview < ActiveRecord::Base
	belongs_to :user
	belongs_to :professional, class_name: "User", foreign_key: "pro_id"

  def rating
		user_rating = ProRating.where(user: user, professional: professional).first
		if user_rating.present?
			user_rating.rating
		else
			0
		end
  end
end