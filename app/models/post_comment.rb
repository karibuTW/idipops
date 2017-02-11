# == Schema Information
#
# Table name: pro_comments
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  post_id     :integer
#  last_read_at    :datetime
#  unread          :boolean          default(FALSE)
#  notified        :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class PostComment < ActiveRecord::Base
	belongs_to :user
	belongs_to :post
	has_many :users_favorite_post_comments, dependent: :destroy
	has_many :post_comment_user_mentions, dependent: :destroy

	def send_notifications
    self.unread = true
		if post.user != user
      if post.post_comments.where(unread: true, notified: true).count == 0
        if post.user.online
          Fiber.new do
            WebsocketRails["user_#{post.user.id}"].trigger(:post_comment_new, { post_id: post.id, post_title: post.title, from_user: user.pretty_name })
          end.resume
        else
          NotificationMailer.new_post_comment_email(user.id, post.user.id, self.id).deliver
        end
        self.notified = true
      end
    end
    self.save

    post_comment_user_mentions.each do |user_mention|
			if user_mention.user.online
        Fiber.new do
          WebsocketRails["user_#{user_mention.user.id}"].trigger(:post_comment_mention_new, { post_id: post.id, post_title: post.title, from_user: user.pretty_name })
        end.resume
      else
        NotificationMailer.new_post_comment_mention_email(user_mention.user.id, post.id).deliver
      end
      user_mention.update(notified: true, unread: true)
    end
	end

end