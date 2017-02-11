class AddAncestryDepthToProfessions < ActiveRecord::Migration
  def change
    add_column :professions, :ancestry_depth, :integer, default: 0, after: :ancestry
  end
end
