class AddRejectReasonToClassifiedAd < ActiveRecord::Migration
  def change
    add_column :classified_ads, :reject_reason, :text, after: :workflow_state
  end
end
