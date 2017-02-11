class AddSpecificFieldsToQuotationRequests < ActiveRecord::Migration
  def change
    add_column :quotation_requests, :specific_fields, :text, after: :quotation_name
    remove_column :quotation_requests, :building_type, :string
    remove_column :quotation_requests, :other_building_type, :string
    remove_column :quotation_requests, :prestation, :int
    remove_column :quotation_requests, :surface_description, :text
    remove_column :quotation_requests, :options, :text
  end
end
