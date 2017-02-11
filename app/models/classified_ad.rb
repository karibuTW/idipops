# == Schema Information
#
# Table name: classified_ads
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  description    :text
#  start_date     :datetime
#  user_id        :integer
#  place_id       :integer
#  workflow_state :string(255)
#  reject_reason  :text
#  created_at     :datetime
#  updated_at     :datetime
#

class ClassifiedAd < ActiveRecord::Base
	include Workflow

	after_create :publish_if_not_first

	belongs_to :user
	belongs_to :place
	has_and_belongs_to_many :professions
	has_many :quotation_requests
	has_many :conversations
	has_many :authorizations
	has_many :classified_ad_photos

	scope :updated_desc, -> { order(updated_at: :desc) }
	scope :created_desc, -> { order(created_at: :desc) }
	scope :with_quotation_request, -> { where("workflow_state='private'") }
	scope :active, -> { where("workflow_state='published'") }
	scope :inactive, -> { where("workflow_state='inactive' OR workflow_state='closed' OR workflow_state='pending'") }
	scope :rejected, -> { where("workflow_state='rejected' OR workflow_state='reported'") }

	workflow do
		state :pending do
			event :accept, transitions_to: :published
			event :reject, transitions_to: :rejected
		end
		state :rejected do
			event :submit, transitions_to: :pending
			event :publish, transitions_to: :published
		end
		state :published do
			event :close, transitions_to: :closed
			event :suspend, transitions_to: :inactive
			event :report, transitions_to: :reported
			event :reject, transitions_to: :rejected
		end
		state :reported do
			event :accept, transitions_to: :published
			event :reject, transitions_to: :rejected
			event :close, transitions_to: :closed
		end
		state :inactive do
			event :publish, transitions_to: :published
			event :close, transitions_to: :closed
		end
		state :private do
			event :make_public, transitions_to: :published, :if => proc { |qr| qr.can_be_automatically_published? }
			event :make_public, transitions_to: :pending
			event :close, transitions_to: :closed
		end
		state :closed
	end

	def close
		self.conversations.each do |conversation|
			if conversation.can_reject?
				conversation.reject!
				other_user = conversation.users.where.not(id: self.user.id).first
        system_message = Message.create(conversation: conversation, user: self.user, system_generated: true, content: { type: "offer_rejected", reason: I18n.t("classified_ad.closed_by_user") }.to_json )
        if other_user.online
        	qr_id = nil
        	quotation_request = self.quotation_requests.joins(:professionals).where("quotation_requests_professionals.user_id = ?", other_user.id).first
		      if quotation_request.present?
		        qr_id = quotation_request.id
		      end
          Fiber.new do
            WebsocketRails["user_#{other_user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: self.user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: other_user, unread: true).count, owner: { clad_id: conversation.classified_ad.id, qr_id: qr_id } })
          end.resume
        else
          NotificationMailer.rejected_conversation_email(conversation.id, other_user.id, I18n.t("classified_ad.closed_by_user")).deliver
        end
      end
		end
	end

	def reject(reason)
		update(reject_reason: reason)
		NotificationMailer.rejected_classified_ad_email(self.id).deliver
	end

	def report(reason)
		update(reject_reason: reason)
		NotificationMailer.reported_classified_ad_email(self.id).deliver
		AdminMailer.reported_classified_ad_to_review_email(self.id).deliver
	end

	def submit
		AdminMailer.classified_ad_to_approve_email(self.id).deliver
	end

	def publish_if_not_first
		if pending? && can_be_automatically_published?
			accept!
		else
			AdminMailer.classified_ad_to_approve_email(self.id).deliver
		end
	end

	def can_be_automatically_published?
		 return user.classified_ads.with_published_state.count > 0 || user.classified_ads.with_inactive_state.count > 0 || user.classified_ads.with_closed_state.count > 0
	end

	def truncated_description
		ActionController::Base.helpers.truncate(description, length: 200, separator: " ")
	end
end
