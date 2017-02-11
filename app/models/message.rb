# == Schema Information
#
# Table name: messages
#
#  id               :integer          not null, primary key
#  conversation_id  :integer
#  user_id          :integer
#  system_generated :boolean          default(FALSE)
#  content          :text
#  created_at       :datetime
#  updated_at       :datetime
#

class Message < ActiveRecord::Base

  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true
  validates_presence_of :conversation  
  validates_presence_of :user, :if => :user_required?

  after_create :update_unread_status

  before_validation :sanitize_fields

  private

  def user_required?
    !self.system_generated
  end

  def update_unread_status
    # update the conversation updated_at column
    conversation.update_column(:updated_at, DateTime.now)
    
    conversation.users.each do |u|
      # update the conversation users unread column
      unless user.present? && user == u
        # when it's not a message send by u
        cu = u.conversation_users.where(conversation: conversation).first
        if user.present? && !cu.unread
          # set notified to false only if it is a non-system message (system messages have separate emails)
          # set notified to false only if the conversation wasn't unread (to prevent getting too many messages about a conversation)
          cu.notified = false 
        end
        cu.unread = true
        cu.save
      end
    end
  end

  def sanitize_fields
    self.content = HTML::FullSanitizer.new.sanitize(self.content) if self.content.present?
  end

end
