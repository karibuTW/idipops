# == Schema Information
#
# Table name: authorizations
#
#  id                    :integer          not null, primary key
#  credit_transaction_id :integer
#  classified_ad_id      :integer
#

class AuthorizationSerializer < BaseSerializer

  attributes :classified_ad_id,
             :credit_transaction_id,
             :balance

  def balance
  	object.credit_transaction.user.balance
  end

end
