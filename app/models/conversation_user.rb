# == Schema Information
#
# Table name: conversation_users
#
#  id              :integer          not null, primary key
#  conversation_id :integer
#  user_id         :integer
#  unread          :boolean          default(FALSE)
#  last_read_at    :datetime
#  notified        :boolean          default(FALSE)
#

class ConversationUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :conversation

  before_create :set_last_read_now

  private
  
  def set_last_read_now
    self.last_read_at = DateTime.now
  end

end
