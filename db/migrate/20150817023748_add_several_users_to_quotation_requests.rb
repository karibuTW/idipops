class AddSeveralUsersToQuotationRequests < ActiveRecord::Migration
  def change
  	create_table :quotation_requests_professionals, id: false do |t|
      t.belongs_to :quotation_request, index: true
      t.belongs_to :user, index: true
    end

    execute "INSERT INTO quotation_requests_professionals (quotation_request_id, user_id) SELECT id, professional_id FROM quotation_requests"

  	remove_column :quotation_requests, :professional_id, index: true
  end
end
