# == Schema Information
#
# Table name: deal_promotions
#
#  id          						:int          not null, primary key
#  credit_transaction_id 	:int					index
#  deal_id 								:int
#  display_location 			:varchar(255)
#  initial_impressions 		:int 					default: 0
#  remaining_impressions 	:int 					default: 0
#  created_at  						:datetime
#  updated_at  						:datetime
#
class DealPromotion < ActiveRecord::Base
	acts_as_taggable

	belongs_to :deal
	has_and_belongs_to_many :credit_transactions, join_table: "deal_promotions_transactions"
	
end