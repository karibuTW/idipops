class AddReporterIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :reporter_id, :int, after: :workflow_state, index:true
    add_column :posts, :reject_reason, :text, after: :workflow_state
  end
end
