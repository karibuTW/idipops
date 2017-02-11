# == Schema Information
#
# Table name: price_for_categories
#
#  id                  :integer          not null, primary key
#  credit_amount       :integer
#  amount_cents        :integer          default(0), not null
#  amount_currency     :string(255)      default("EUR"), not null
#  pricing_category_id :integer
#  pricing_id          :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class PriceForCategory < ActiveRecord::Base
	monetize :amount_cents

	belongs_to :pricing_category
	belongs_to :pricing

	validates :credit_amount, presence: true
end
