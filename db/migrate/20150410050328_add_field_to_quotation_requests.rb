class AddFieldToQuotationRequests < ActiveRecord::Migration
  def change
    add_column :quotation_requests, :building_type, :string, after: :classified_ad_id
    add_column :quotation_requests, :other_building_type, :string, after: :building_type
    add_column :quotation_requests, :prestation, :integer, after: :other_building_type
    add_column :quotation_requests, :surface_description, :text, after: :prestation
    add_column :quotation_requests, :options, :text, after: :surface_description
  end
end
