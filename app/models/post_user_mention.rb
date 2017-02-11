# == Schema Information
#
# Table name: post_user_mentions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  post_id     :integer
#  last_read_at    :datetime
#  unread          :boolean          default(FALSE)
#  notified        :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class PostUserMention < ActiveRecord::Base
	belongs_to :user
	belongs_to :post

end