# == Schema Information
#
# Table name: quotation_request_professionals
#
#  id          			:integer          not null, primary key
#  quotation_request_id    	:integer          not null, index
#  user_id  		:integer          not null, index
#  quotation_uid  		:varchar(255)
#  quotation_name  		:varchar(255)
#
class QuotationRequestProfessional < ActiveRecord::Base
	dragonfly_accessor :quotation
	
	belongs_to :professional, class_name: "User", foreign_key: "user_id"
	belongs_to :quotation_request
end