class AddQuotationToQuotationRequests < ActiveRecord::Migration
  def change
    add_column :quotation_requests, :quotation_uid, :string, after: :classified_ad_id
    add_column :quotation_requests, :quotation_name, :string, after: :quotation_uid
  end
end
