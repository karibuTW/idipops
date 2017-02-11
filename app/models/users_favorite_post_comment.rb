# == Schema Information
#
# Table name: users_favorite_post_comments
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  post_comment_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class UsersFavoritePostComment < ActiveRecord::Base
	belongs_to :user
	belongs_to :post_comment

end
