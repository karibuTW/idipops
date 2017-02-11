# == Schema Information
#
# Table name: quotation_requests
#
#  id          			:integer          not null, primary key
#  classified_ad_id    	:integer          not null, index
#  customer_id  		:integer          not null, index
#  specific_fields 		:text
#  created_at  			:datetime
#  updated_at 			:datetime
#
class QuotationRequest < ActiveRecord::Base
	
	has_many :quotation_request_professionals
	has_many :professionals, through: :quotation_request_professionals, source: :professional
	belongs_to :customer, class_name: "User", foreign_key: "customer_id"
	belongs_to :classified_ad
	
	scope :updated_desc, -> { order(updated_at: :desc) }
end