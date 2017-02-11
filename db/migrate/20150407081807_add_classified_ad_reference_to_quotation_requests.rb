class AddClassifiedAdReferenceToQuotationRequests < ActiveRecord::Migration
  def change
    add_reference :quotation_requests, :classified_ad, index: true, after: :professional_id
  end
end
