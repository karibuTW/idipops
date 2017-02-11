class AddWorkflowStateToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :workflow_state, :string, after: :classified_ad_id
  end
end
