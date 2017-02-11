class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true
      t.string :auth_type
      t.integer :object_id, index: true
      t.references :transaction, index: true
    end
  end
end
