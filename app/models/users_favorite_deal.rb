# == Schema Information
#
# Table name: users_favorite_deals
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  deal_id				 :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class UsersFavoriteDeal < ActiveRecord::Base
	belongs_to :user
	belongs_to :deal, counter_cache: true, touch: true

end
