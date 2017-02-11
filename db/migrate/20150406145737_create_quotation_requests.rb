class CreateQuotationRequests < ActiveRecord::Migration
  def change
    create_table :quotation_requests do |t|
    	t.belongs_to :customer, index: true
      t.belongs_to :professional, index: true
      t.timestamps null: false
    end
  end
end
