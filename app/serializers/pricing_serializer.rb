# == Schema Information
#
# Table name: pricings
#
#  id         :integer          not null, primary key
#  target     :string(255)
#  start_date :datetime
#  created_at :datetime
#  updated_at :datetime
#

class PricingSerializer < BaseSerializer

  attributes :target,
             :credit_amount,
             :amount_cents
  def credit_amount
  	if current_user.primary_activity.present?
	  	return object.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category).credit_amount
	  else
	  	return 0
	  end
  end

  def amount_cents
  	if current_user.primary_activity.present?
	  	return object.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category).amount_cents
	  else
	  	return 0
	  end
  end

end
