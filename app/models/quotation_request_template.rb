# == Schema Information
#
# Table name: quotation_request_templates
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  fields     :text
#  model      :text
#  created_at :datetime
#  updated_at :datetime
#

class QuotationRequestTemplate < ActiveRecord::Base
	
	has_many :professions
	
end
