# == Schema Information
#
# Table name: credit_transactions
#
#  id          	:integer          not null, primary key
#  description  :string
#  user_id    	:integer          not null, index
#  amount_cents :int
#  amount_currency :text
#  credit_amount :int
#  ext_transaction_id :string
#  workflow_state :string
#  invoice_uid		:string
#  created_at  	:datetime
#  updated_at  	:datetime
#
class CreditTransaction < ActiveRecord::Base
	include Workflow
	
	belongs_to :user
	has_one :authorization
	has_and_belongs_to_many :deal_promotions, join_table: "deal_promotions_transactions"
	monetize :amount_cents
	dragonfly_accessor :invoice

	workflow do
		state :pending do
			event :accept, transitions_to: :done
			event :reject, transitions_to: :rejected
			event :cancel, transitions_to: :cancelled
		end
		state :rejected
		state :done
		state :cancelled
	end
end