# == Schema Information
#
# Table name: authorizations
#
#  id                    :integer          not null, primary key
#  credit_transaction_id :integer
#  classified_ad_id      :integer
#

class Authorization < ActiveRecord::Base

  # belongs_to :user
  belongs_to :credit_transaction
  belongs_to :classified_ad

end
