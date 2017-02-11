# == Schema Information
#
# Table name: deals
#
#  id                 :integer          not null, primary key
#  tagline            :string(255)
#  description        :text
#  start_date         :datetime
#  end_date           :datetime
#  user_id            :integer
#  featured_image_uid :string(255)
#  list_image_uid     :string(255)
#  users_favorite_deals_count :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Deal < ActiveRecord::Base
	after_update :set_date_to_midnight

	dragonfly_accessor :list_image
	dragonfly_accessor :featured_image
	
	belongs_to :user
	has_and_belongs_to_many :addresses
	has_many :deal_promotions
	has_many :users_favorite_deals, dependent: :destroy

	validates :tagline, presence: true, on: :update
	validates :description, presence: true, on: :update
	validates_presence_of :user

	scope :active, -> { where("CURDATE() >= start_date AND CURDATE() <= end_date") }

	def set_date_to_midnight
		update_column(:start_date, start_date.beginning_of_day)
		update_column(:end_date, end_date.end_of_day)
	end

end
