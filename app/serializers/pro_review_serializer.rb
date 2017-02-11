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

class ProReviewSerializer < BaseSerializer

  attributes :id,
             :content,
             :updated_at,
             :avatar_url,
             :rating,
             :name

  def avatar_url
    if object.user.avatar_uid.present?
      object.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def rating
  	user_rating = ProRating.where(user: object.user, professional: object.professional).first
  	if user_rating.present?
  		user_rating.rating
  	else
  		0
  	end
  end

  def name
  	"#{object.user.first_name} #{object.user.last_name[0]}."
  end

end
