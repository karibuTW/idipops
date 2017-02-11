class ClassifiedAdListSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :updated_at,
             :user_display_name,
             :user_avatar_url,
             :place_name,
             :status,
             :views,
             :unread_conversations_count,
             :quotation_request_id

  # has_many :quotation_requests, serializer: OutgoingQuotationRequestListSerializer

  def status
    object.current_state.name
  end

  def views
    object.authorizations.count
  end

  def description
    object.truncated_description
  end

  def place_name
    object.place.formatted_name
  end

  def user_display_name
  	object.user.display_name
  end

  def user_avatar_url
    if object.user.avatar_uid.present?
      object.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def unread_conversations_count
    if current_user.is_pro?
      if object.conversations.present?
        ConversationUser.where( user: current_user, unread: true, conversation: object.conversations).count
      else
        return 0
      end
    else
      if object.conversations.present? && object.quotation_requests.count == 0
        ConversationUser.where( user: current_user, unread: true, conversation: object.conversations).count
      else
        return 0
      end
    end
  end

  def quotation_request_id
    if current_user.is_pro?
      # quotation_request = object.quotation_requests.joins(:professionals).where("quotation_requests_professionals.user_id = ?", current_user.id).first
      quotation_request = object.quotation_requests.joins(:quotation_request_professionals).where(quotation_request_professionals: {professional: current_user}).first
      if quotation_request.present?
        quotation_request.id
      else
        nil
      end
    else
      if object.quotation_requests.count == 1
        object.quotation_requests.first.id
      else
        nil
      end
    end
  end

end