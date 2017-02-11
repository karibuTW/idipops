class RenameQuotationRequestsProfessionalToQuotationRequestProfessional < ActiveRecord::Migration
  def change
  	rename_table :quotation_requests_professionals, :quotation_request_professionals
  end
end
