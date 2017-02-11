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

class QuotationRequestTemplateSerializer < BaseSerializer

	attributes 	:name,
							:fields,
							:model

end
