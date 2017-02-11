class AddQuotationRequestTemplateToProfessions < ActiveRecord::Migration
  def change
    add_reference :professions, :quotation_request_template, index: true, after: :ancestry_depth
  end
end
