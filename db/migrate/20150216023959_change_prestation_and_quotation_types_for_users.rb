class ChangePrestationAndQuotationTypesForUsers < ActiveRecord::Migration
  def change
  	change_column :users, :quotation, :boolean
  	change_column :users, :prestation, :boolean
  end
end
