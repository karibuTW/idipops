class AddPricingCategoryToProfessions < ActiveRecord::Migration
  def change
    add_reference :professions, :pricing_category, index: true, after: :quotation_request_template_id
    add_reference :pricings, :pricing_category, index: true, after: :start_date
  end
end
