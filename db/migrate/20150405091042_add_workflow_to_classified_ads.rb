class AddWorkflowToClassifiedAds < ActiveRecord::Migration
  def change
    add_column :classified_ads, :workflow_state, :string, after: :place_id
  end
end
