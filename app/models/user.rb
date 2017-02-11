# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer
#  company_name           :string(255)
#  pretty_name            :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  name_is_public         :boolean          default(TRUE)
#  user_type              :string(255)
#  birthdate              :date
#  website                :string(255)
#  siret                  :string(255)
#  admin                  :boolean          default(FALSE)
#  first_login            :datetime
#  last_login             :datetime
#  short_description      :text
#  long_description       :text
#  client_references      :text
#  advantages             :text
#  land_phone             :string(255)
#  mobile_phone           :string(255)
#  fax                    :string(255)
#  avatar_uid             :string(255)
#  primary_activity_id    :integer
#  secondary_activity_id  :integer
#  tertiary_activity_id   :integer
#  token                  :string(255)
#  quaternary_activity_id :integer
#  prestation             :boolean
#  quotation              :boolean
#  hourly_rate            :decimal(8, 2)    default(-1.0)
#  place_id               :integer
#  online                 :boolean          default(FALSE)
#  newsletter             :boolean          default(TRUE)
#  points                 :integer          default(0), not null
#  rating                 :integer          default(0)
#  premium_posts					:boolean
#  created_at             :datetime
#  updated_at             :datetime
#  token 					        :string(255)
#  workflow_state         :string(255)      default("active")
#
class User < ActiveRecord::Base
	include Workflow
	include Tokenable

	dragonfly_accessor :avatar do
		default 'public/images/avatar.png'
	end

	acts_as_taggable

	belongs_to :primary_activity, class_name: "Profession", foreign_key: "primary_activity_id"
	belongs_to :secondary_activity, class_name: "Profession", foreign_key: "secondary_activity_id"
	belongs_to :tertiary_activity, class_name: "Profession", foreign_key: "tertiary_activity_id"
	belongs_to :quaternary_activity, class_name: "Profession", foreign_key: "quaternary_activity_id"
	belongs_to :place
	belongs_to :account
	has_many :classified_ads
	has_many :user_photos
	# has_many :authorizations
	has_many :addresses
	has_many :credit_transactions
	# has_many :incoming_quotations, class_name: "QuotationRequest", foreign_key: "professional_id"
	has_many :quotation_request_professionals
	has_many :incoming_quotation_requests, through: :quotation_request_professionals, source: :quotation_request
	has_many :outgoing_quotation_requests, class_name: "QuotationRequest", foreign_key: "customer_id"
	# has_many :professionals, -> { where user_type: 'pro' }, class_name: "User", through: :outgoing_quotations
	# has_many :customers, -> { where user_type: 'particulier' }, class_name: "User", through: :incoming_quotations
	has_many :conversation_users
	has_many :conversations, through: :conversation_users
	has_many :deals, -> { where user_type: 'pro' }
	has_many :users_favorite_professionals
	has_many :favorite_professionals, through: :users_favorite_professionals
	has_many :customer_reviews, ->(user) { where user.user_type == 'pro'}, class_name: "ProReview", foreign_key: "pro_id"
	has_many :pro_reviews, ->(user) { where user.user_type == 'particulier'}, class_name: "ProReview", foreign_key: "pro_id"
	has_many :referrals,class_name: "Referral", foreign_key: "referrer_id"
	has_many :processed_referrals,-> {where workflow_state: 'processed'}, class_name: "Referral", foreign_key: "referrer_id"
	has_one :referral, -> {where workflow_state: 'processed'},class_name: "Referral", foreign_key: "customer_id"
	has_many :referral_users,through: :referrals, source: :customer
	has_many :processed_referral_users,through: :processed_referrals, source: :customer
	has_one :referrer,through: :referral,source: :referrer
	has_many :posts
	has_many :post_category_subscriptions
	has_many :post_categories, through: :post_category_subscriptions
	has_many :post_comments, dependent: :destroy
	has_many :post_subscribers, class_name: "PostAuthorSubscription", foreign_key: "author_id"
	has_many :post_author_subscriptions, dependent: :destroy
	has_many :post_user_mentions
	has_many :post_comment_user_mentions
	has_many :users_favorite_posts, dependent: :destroy
	has_many :favorite_posts, through: :users_favorite_posts, source: :post
	has_many :users_favorite_post_comments, dependent: :destroy
	has_many :favorite_post_comments, through: :users_favorite_post_comments, source: :post_comment
	has_many :users_favorite_deals, dependent: :destroy
	has_many :favorite_deals, through: :users_favorite_deals, source: :deal
	validates :company_name, presence: true, length: {maximum: 80}, if: ->(user){user.user_type == 'pro'}, on: :update
	# validates :address, presence: true, length: {maximum: 255}, if: ->(user){user.user_type == 'pro'}, on: :update
	validates :place, presence: true, length: {maximum: 255}, if: ->(user){user.user_type == 'particulier'}, on: :update
	validates :short_description, allow_blank: true, length: {maximum: 100}
	validates :long_description, allow_blank: true, length: {maximum: 400}
	validates :client_references, allow_blank: true, length: {maximum: 400}
	validates :advantages, allow_blank: true, length: {maximum: 200}
	validates :website, allow_blank: true, length: {maximum: 255}
	validates :siret, allow_blank: true, length: {maximum: 14}
	# validates :pretty_name, presence: true, uniqueness: { case_sensitive: false }, :format => { :with => /[a-zA-Z0-9]+/i }, on: :update
	scope :with_activity, -> (profession_ids) { where("primary_activity_id in (?) or secondary_activity_id in (?) or tertiary_activity_id in (?) or quaternary_activity_id in (?)", profession_ids, profession_ids, profession_ids, profession_ids) }
	scope :pro, -> { where(user_type: 'pro') }
	scope :active, -> { where(workflow_state: "active") }

	workflow do
		state :active do
			event :deactivate, transitions_to: :inactive
			event :pause, transitions_to: :paused
		end
		state :inactive do
			event :activate, transitions_to: :active
			event :pause, transitions_to: :paused
		end
		state :paused do
			event :activate, transitions_to: :active
			event :deactivate, transitions_to: :inactive
		end
	end

	class << self
		def load_or_search(options = {})
			query = self.joins(account: :account_emails)
			if options[:keyword].present?
				sanitized_key = "%#{ options[:keyword].strip.downcase }%"
				sql = "LOWER(CONCAT(first_name,' ',last_name)) LIKE :keyword"\
                    " OR LOWER(company_name) LIKE :keyword"\
                    " OR LOWER(account_emails.email) LIKE :keyword"
				query = query.where(sql, keyword: sanitized_key)
			end
			query.includes(account: :account_emails)
		end
	end
	
	def log_signin
		self.first_login = Time.now if self.first_login.nil?
		self.last_login = Time.now
		if self.user_type.present? && !self.pretty_name.present?
			create_nickname
		end
		self.save
	end

	def is_pro?
		user_type.present? && user_type == 'pro'
	end

	def is_particulier?
		user_type.present? && user_type == 'particulier'
	end

	def complete?
		if user_type.present?
			if user_type == 'pro'
				return company_name.present? && addresses.length > 0 && short_description.present? && long_description.present?
			elsif user_type == 'particulier'
				return first_name.present? && last_name.present?
			end
		else
			return false
		end
	end

	def balance
		return self.credit_transactions.with_done_state.sum(:credit_amount)
	end

	def total_referral_rewards
		return self.processed_referral_users.sum(:reward)
	end

	def display_name
		if is_pro?
			company_name
		else
			"#{first_name} #{last_name}"
		end
	end

	def profession_ids
		profession_ids = Array.new()
		if is_pro? && primary_activity.present?
			profession_ids << primary_activity.id
			if secondary_activity.present?
				profession_ids << secondary_activity.id
				if tertiary_activity.present?
					profession_ids << tertiary_activity.id
					profession_ids << quaternary_activity.id if quaternary_activity.present?
				end
			end
		end
		return profession_ids
	end

	def authorized_classified_ad_ids
		credit_transactions.select('authorizations.*').joins(:authorization).where('authorizations.credit_transaction_id = credit_transactions.id').pluck(:classified_ad_id)
	end

	def add_credits(n)
		transaction = self.credit_transactions.create(credit_amount: n, description: "admin_operation")
    transaction.accept!
	end

	def subtract_credits(n)
		transaction = self.credit_transactions.create(credit_amount: -n, description: "admin_operation")
    transaction.accept!
	end

	def create_and_send_referral_emails(emails,subject,message)
		regex = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
		emails = emails.reject{|e| e.blank? || (e =~ regex) != 0}
		pricing = Pricing.active('bonus_referral')
		price_for_category = pricing.price_for_categories.last
		reward = price_for_category.present? ? price_for_category.credit_amount : 0
		self.transaction do
			emails.each do |email|
				Referral.find_or_create_by(referrer: self,email: email,reward: reward)
			end
		end
		NotificationMailer.referral_users_email(self.id,emails,subject,message).deliver
	end

	def accept_referral_by_token(email, token = nil)
    if token.present? 
    	referrer = User.find_by(token: token)
    	if referrer	    	
	      referral = Referral.find_by(referrer: referrer,email: email)
	      unless referral
	      	pricing = Pricing.active('bonus_referral')
					price_for_category = pricing.price_for_categories.last
					reward = price_for_category.present? ? price_for_category.credit_amount : 0
	      	referral = Referral.create(referrer: referrer,customer: self,email: email,reward: reward)
	      end
	    end
    else
    	referral = Referral.find_by(email: email)    	
  	end
  	if referral && referral.pending?
      referral.customer = self
      referral.save
      referral.register!
    end
	end

	def posts_from_subscriptions
		Post.where(post_category_id: self.post_category_subscriptions.pluck(:post_category_id)).union(Post.where(user_id: self.post_author_subscriptions.pluck(:author_id)))
	end

	before_validation :check_website
	before_validation :create_slug

	private

	def create_slug
		if self.user_type == 'pro'
	    create_nickname
	  end
  end

  def create_nickname
  	if !self.pretty_name.present?
	    self.pretty_name = display_name.parameterize
	    i = 1
	    while !self.valid? do
	    	if self.errors[:pretty_name].empty?
	    		break
	    	else
		    	self.pretty_name = display_name.parameterize + i.to_s
		    	i += 1
		    end
	    end
	  end
  end

	def check_website
		if self.website.present?
			unless self.website[/\Ahttp:\/\//] || self.website[/\Ahttps:\/\//]
				self.website = "http://#{self.website}"
			end
		end
	end
end
