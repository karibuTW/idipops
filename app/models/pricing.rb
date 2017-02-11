# == Schema Information
#
# Table name: pricings
#
#  id         :integer          not null, primary key
#  target     :string(255)
#  start_date :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Pricing < ActiveRecord::Base
	validates :start_date, presence: true
	validates :target, presence: true

	has_many :price_for_categories
	has_many :pricing_categories, through: :price_for_categories

	def self.active(target)
		where(target: target).where("start_date <= NOW()").order(start_date: :desc).first
	end

	def active?
		start_date <= Date.today && Pricing.where(target: target).where("start_date <= NOW() && start_date > ?", start_date).count == 0 && pricing_categories.count == PricingCategory.all.count
	end
end
