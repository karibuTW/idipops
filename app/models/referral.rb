class Referral < ActiveRecord::Base
	include Workflow

	belongs_to :customer,class_name: "User", foreign_key: "customer_id"
	belongs_to :referrer, class_name: "User", foreign_key: "referrer_id"
	validates :referrer_id, presence: true
	validate :check_customer_exists

	workflow do
		state :pending do
			event :register, transitions_to: :registered
		end
		state :registered do
			event :process, transitions_to: :processed
		end
		state :processed
	end

	def process_reward
		pricing = Pricing.active('bonus_referral')
		if pricing.present?
			if customer.user_type == 'pro'
				price_for_category = pricing.price_for_categories.find_by(pricing_category: customer.primary_activity.pricing_category)
				transaction = CreditTransaction.create(user: customer, credit_amount: price_for_category.credit_amount, description: "bonus_referral")
				transaction.accept!
			end
			if referrer.user_type == 'pro'
				self.process!
				price_for_category = pricing.price_for_categories.find_by(pricing_category: referrer.primary_activity.pricing_category)
				transaction = CreditTransaction.create(user: referrer, credit_amount: price_for_category.credit_amount, description: "bonus_referral")
				transaction.accept!
				NotificationMailer.processed_referral_email(referrer.id,customer.account.account_emails.first.email,price_for_category.credit_amount).deliver
			end
		end
	end

	private

	def check_customer_exists
	  self.errors.add(:customer_id, 'doit être rempli(e)') unless customer_id.present? || email.present?
	end

end