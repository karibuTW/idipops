class AddQuotationToQuotationRequestsProfessionals < ActiveRecord::Migration
  def change
    add_column :quotation_requests_professionals, :id, :primary_key, first: true
    add_column :quotation_requests_professionals, :quotation_name, :string, after: :user_id
    add_column :quotation_requests_professionals, :quotation_uid, :string, after: :user_id

    execute "UPDATE quotation_requests_professionals, quotation_requests SET quotation_requests_professionals.quotation_name=quotation_requests.quotation_name, quotation_requests_professionals.quotation_uid=quotation_requests.quotation_uid WHERE quotation_requests_professionals.quotation_request_id = quotation_requests.id"

    remove_column :quotation_requests, :quotation_name, :string
    remove_column :quotation_requests, :quotation_uid, :string
  end
end
