class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.references :classified_ad, index: true
      t.timestamps null: false
    end
  end
end
