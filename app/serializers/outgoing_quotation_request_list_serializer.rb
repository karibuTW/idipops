class OutgoingQuotationRequestListSerializer < BaseSerializer

	attributes 	:id,
              :title,
              :description,
							:user_display_name,
	            :user_avatar_url,
	            :created_at,
              :updated_at,
              :unread_conversations_count,
              :num_of_quotations,
              :num_of_requests,
              :classified_ad_id,
              :classified_ad_status

  def classified_ad_id
    object.classified_ad.id
  end

  def classified_ad_status
    object.classified_ad.current_state.name
  end

  def title
    object.classified_ad.title
  end

  def description
    object.classified_ad.truncated_description
  end

	def user_display_name
  	object.professionals.map(&:display_name).join(', ').truncate(80)
  end

  def user_avatar_url
    if object.professionals.count > 1
      '/images/multi-user.svg'
    elsif object.professionals.first.avatar_uid.present?
      object.professionals.first.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def unread_conversations_count
    if object.classified_ad.conversations.present?
      ConversationUser.where( user: current_user, unread: true, conversation: object.classified_ad.conversations).count
    else
      return 0
    end
  end

  def num_of_quotations
    object.quotation_request_professionals.where.not(quotation_uid: nil).count
  end

  def num_of_requests
    object.quotation_request_professionals.count
  end

end