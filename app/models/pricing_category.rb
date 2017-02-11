# == Schema Information
#
# Table name: pricing_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class PricingCategory < ActiveRecord::Base
	has_many :price_for_categories
	has_many :pricings, through: :price_for_categories
	has_many :professions
end
