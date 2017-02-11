# == Schema Information
#
# Table name: professions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  description                   :text
#  active                        :boolean
#  ancestry                      :string(255)
#  ancestry_depth                :integer          default(0)
#  quotation_request_template_id :integer
#  pricing_category_id           :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#  image_uid                     :string(255)
#

class Profession < ActiveRecord::Base
	dragonfly_accessor :image
	
	has_ancestry cache_depth: true
	has_many :professionals, -> { where user_type: 'pro' }, class_name: "User"
	has_and_belongs_to_many :classified_ads
	belongs_to :quotation_request_template
	belongs_to :pricing_category
	has_and_belongs_to_many :post_categories

	validates :name, presence: true, uniqueness: true

	scope :active, -> { where(active: true) }
end
