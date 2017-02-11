class IncomingQuotationRequestListSerializer < BaseSerializer

	attributes 	:id,
							:user_display_name,
	            :user_avatar_url,
	            :created_at,
              :updated_at,
              :title,
              :description,
              :place_name,
              :authorized,
              :classified_ad_id,
              :unread_conversations_count

  def place_name
    object.classified_ad.place.formatted_name
  end

  def title
    object.classified_ad.title
  end

  def description
    object.classified_ad.truncated_description
  end

	def user_display_name
  	object.customer.display_name
  end

  def user_avatar_url
  	if object.customer.avatar_uid.present?
      object.customer.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def authorized
    object.classified_ad.id.in? current_user.authorized_classified_ad_ids
  end

  def unread_conversations_count
    if object.classified_ad.conversations.present?
      ConversationUser.where( user: current_user, unread: true, conversation: object.classified_ad.conversations).count
    else
      return 0
    end
  end

end