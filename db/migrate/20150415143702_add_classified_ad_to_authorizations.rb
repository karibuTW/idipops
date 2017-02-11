class AddClassifiedAdToAuthorizations < ActiveRecord::Migration
  def change
    add_reference :authorizations, :classified_ad, index: true
    remove_column :authorizations, :object_id, :integer, index: true
    remove_reference :authorizations, :user, index: true
    remove_column :authorizations, :auth_type, :string
  end
end
