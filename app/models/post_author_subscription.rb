# == Schema Information
#
# Table name: post_author_subscriptions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  author_id     :integer
#  last_read_at    :datetime
#  unread          :boolean          default(FALSE)
#  notified        :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class PostAuthorSubscription < ActiveRecord::Base
	belongs_to :user
	belongs_to :author, class_name: "User", foreign_key: "author_id"
end
