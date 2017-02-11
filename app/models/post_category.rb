# == Schema Information
#
# Table name: posts
#
#  id                     :integer          not null, primary key
#  name                          :string(255)
#  active                        :boolean
#  ancestry                      :string(255)
#  ancestry_depth                :integer          default(0)
#  created_at             :datetime
#  updated_at             :datetime
#
class PostCategory < ActiveRecord::Base
	
	has_ancestry cache_depth: true

	has_and_belongs_to_many :professions
	has_many :posts
	has_many :post_category_subscriptions
	has_many :users, through: :post_category_subscriptions

	validates :name, presence: true, uniqueness: true

	scope :active, -> { where(active: true) }

end