class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :conversation, index: true
      t.references :user, index: true
      t.boolean :system_generated, default: false
      t.text :content
      t.timestamps
    end
  end
end
