class CreateConversationUser < ActiveRecord::Migration
  def change
    create_table :conversation_users do |t|
      t.references :conversation, index: true
      t.references :user, index: true
      t.boolean :unread, default: false
      t.datetime :last_read_at
      t.boolean :notified, default: false
    end
  end
end
