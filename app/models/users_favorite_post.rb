# == Schema Information
#
# Table name: users_favorite_posts
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  post_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class UsersFavoritePost < ActiveRecord::Base
	belongs_to :user
	belongs_to :post, counter_cache: true, touch: true

end
