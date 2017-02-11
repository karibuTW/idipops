# == Schema Information
#
# Table name: posts
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  slug                  :string(255)
#  post_type                   :string(255)
#  description            :text
#  featured_image_uid     :string(255)
#  user_id                :integer
#  post_category_id       :integer
#  workflow_state :string(255)
#  reporter_id            :integer
#  users_favorite_posts_count :integer
#  post_views_count				:integer
#  premium								:boolean
#  created_at             :datetime
#  updated_at             :datetime
#
class Post < ActiveRecord::Base
	require 'sanitize'
	include Workflow

	before_save :sanitize_content
	after_touch :check_premium
	before_validation :create_slug

	dragonfly_accessor :featured_image

	acts_as_taggable

	belongs_to :user
	belongs_to :post_category
	has_many :post_photos, dependent: :destroy
	has_many :post_comments, dependent: :destroy
	has_many :post_views, dependent: :destroy
	has_many :users_favorite_posts, dependent: :destroy
	has_many :post_user_mentions, dependent: :destroy

	validates :slug, uniqueness: { case_sensitive: false }

	workflow do
		state :published do
			event :report, transitions_to: :reported
			event :reject, transitions_to: :rejected
		end
		state :reported do
			event :accept, transitions_to: :published
			event :reject, transitions_to: :rejected
		end
		state :rejected do
			event :accept, transitions_to: :published
		end
	end

	def reject(reason)
		update(reject_reason: reason)
		NotificationMailer.rejected_post_email(self.id).deliver
	end

	def report(reason)
		update(reject_reason: reason)
		NotificationMailer.reported_post_email(self.id).deliver
		AdminMailer.reported_post_to_review_email(self.id).deliver
	end
	
	def truncated_description
		ActionController::Base.helpers.truncate(Sanitize.fragment(description, :elements => ['br'], remove_contents: ['style']), length: 200, separator: " ", escape: false)
	end

	def sanitize_content
		Sanitize.fragment(self.description, Sanitize::Config::RELAXED)
	end

	def mark_read(user, owner)
		now = DateTime.now
		PostAuthorSubscription.where(user: user, author: self.user).update_all(unread: false, last_read_at: now)
		PostCategorySubscription.where(user: user, post_category: self.post_category).update_all(unread: false, last_read_at: now)
		self.post_user_mentions.where(user: user).update_all(unread: false, last_read_at: now)
		PostCommentUserMention.where(user: user, post_comment: self.post_comments).update_all(unread: false, last_read_at: now)
		if owner
			self.post_comments.update_all(unread: false, last_read_at: now)
		end
  end

	def send_notifications
		user_mention_ids = post_user_mentions.pluck(:user_id)
		(user.post_subscribers.pluck(:user_id) + PostCategorySubscription.where(post_category: post_category).pluck(:user_id) - user_mention_ids).uniq.each do |subscriber_id|
			subscribed_user = User.find(subscriber_id)
			pcs = PostCategorySubscription.where(user: subscribed_user, post_category: self.post_category).first 
			pas = PostAuthorSubscription.where(user: subscribed_user, author: self.user).first
			if (!pcs.present? || !pcs.notified) && (!pas.present? || !pas.notified)
				if subscribed_user.online
	        Fiber.new do
	          WebsocketRails["user_#{subscribed_user.id}"].trigger(:post_new, { post_id: id, post_title: title, from_user: user.pretty_name })
	        end.resume
	      else
	        NotificationMailer.new_post_email(subscribed_user.id, id).deliver
	      end
	    end
	    if pcs.present?
	      pcs.update(unread: true, notified: true)
	    end
	    if pas.present?
	      pas.update(unread: true, notified: true)
	    end
    end

    user_mention_ids.each do |subscriber_id|
			mentioned_user = User.find(subscriber_id)
			if mentioned_user.online
        Fiber.new do
          WebsocketRails["user_#{mentioned_user.id}"].trigger(:post_mention_new, { post_id: id, post_title: title, from_user: user.pretty_name })
        end.resume
      else
        NotificationMailer.new_post_mention_email(mentioned_user.id, id).deliver
      end
    end
    post_user_mentions.update_all(unread: true, notified: true)
	end

	def check_premium
		if users_favorite_posts_count > 0 && post_views_count > 0
			ratio = users_favorite_posts_count / post_views_count.to_f
			is_premium = ratio >= ENV['PREMIUM_LIMIT'].to_f
		else
			is_premium = false
		end
		update(premium: is_premium)
	end

	def create_slug
  	if !self.slug.present?
	    self.slug = self.title.parameterize
	    i = 1
	    while !self.valid? do
	    	if self.errors[:slug].empty?
	    		break
	    	else
		    	self.slug = self.title.parameterize + i.to_s
		    	i += 1
		    end
	    end
	  end
  end

end