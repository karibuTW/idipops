# == Schema Information
#
# Table name: post_comment_user_mentions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  post_comment_id     :integer
#  last_read_at    :datetime
#  unread          :boolean          default(FALSE)
#  notified        :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class PostCommentUserMention < ActiveRecord::Base
	belongs_to :user
	belongs_to :post_comment

end