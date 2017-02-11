class AddWorkflowToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :workflow_state, :string, after: :user_id, default: "published"
    change_column :posts, :post_category_id, :int, after: :user_id
  end
end
