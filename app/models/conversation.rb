# == Schema Information
#
# Table name: conversations
#
#  id               :integer          not null, primary key
#  classified_ad_id :integer
#  workflow_state   :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Conversation < ActiveRecord::Base
	include Workflow

  has_many :conversation_users
  has_many :users, through: :conversation_users
  belongs_to :classified_ad

  has_many :messages

  workflow do
		state :pending do
			event :accept, transitions_to: :accepted, :if => proc { |conversation| conversation.can_accept_or_reject? }
			event :reject, transitions_to: :rejected, :if => proc { |conversation| conversation.can_accept_or_reject? }
		end
		state :rejected
		state :accepted
	end

	def can_accept_or_reject?
		return classified_ad.present?
	end

  def mark_read(user)
    cu = conversation_users.where(user: user).first
    if cu.present? 
      if cu.unread
        cu.unread = false
        # cu.notified = false # FIXME: we should not need this
        cu.last_read_at = DateTime.now
        cu.save
      elsif cu.last_read_at.nil? || cu.last_read_at < 5.minutes.ago
        #to keep last_read_at more or less up to date without too many updates
        cu.last_read_at = DateTime.now
        cu.save
      end
    end 
  end

end
