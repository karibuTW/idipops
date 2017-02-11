class RenameReferencesToClientReferencesInUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :references, :client_references
  end
end
