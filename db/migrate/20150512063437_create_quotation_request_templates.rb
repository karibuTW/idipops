class CreateQuotationRequestTemplates < ActiveRecord::Migration
  def change
    create_table :quotation_request_templates do |t|
      t.string :name
      t.text :fields
      t.text :model
      t.timestamps
    end
  end
end
