class AddWorkflowStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :workflow_state, :string, default: "active"
    remove_column :users, :active, :boolean, default: true
  end
end
