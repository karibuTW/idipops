class Api::V1::ClassifiedAdsController < ApiController
	def index
		if signed_in?
      if params.has_key?(:around) && current_user.user_type == 'pro'
        authorized_classified_ad_ids = current_user.authorized_classified_ad_ids
        already_in_leads_classified_ad_ids = current_user.incoming_quotation_requests.pluck(:classified_ad_id)
        classified_ads = Array.new()
        address = Address.find(params[:around])
        relevant_classified_ads = ClassifiedAd.with_published_state.select('classified_ads.*').joins(:professions).where('professions.id IN (?)', current_user.profession_ids).distinct.updated_desc
        if authorized_classified_ad_ids.count > 0
          relevant_classified_ads = relevant_classified_ads.where.not(id: (authorized_classified_ad_ids + already_in_leads_classified_ad_ids))
        end
        # relevant_classified_ads = ClassifiedAd.find_by_sql ["SELECT classified_ads.* FROM `classified_ads` INNER JOIN classified_ads_professions ON classified_ads.id = classified_ads_professions.classified_ad_id WHERE classified_ads.workflow_state = 'published' AND classified_ads_professions.profession_id in (?)", current_user.profession_ids]
        relevant_classified_ads.each do |classified|
          if place_is_in_range( classified.place, address)
            classified_ads << classified
          end
        end
      elsif current_user.user_type == 'particulier'
        if params[:status_type] == 'active'
          classified_ads = current_user.classified_ads.active.updated_desc
        elsif params[:status_type] == 'inactive'
          classified_ads = current_user.classified_ads.inactive.updated_desc
        elsif params[:status_type] == 'rejected'
          classified_ads = current_user.classified_ads.rejected.updated_desc
        else
          classified_ads = current_user.classified_ads.updated_desc
        end
      elsif current_user.user_type == 'pro'
        authorized_classified_ad_ids = current_user.authorized_classified_ad_ids
        if authorized_classified_ad_ids.count > 0
          # classified_ads = get_authorized_classified_ads(authorized_classified_ad_ids, params[:status_type])
          classified_ids_to_remove = classified_ads_where_reply_is('rejected').map(&:id) + classified_ads_where_reply_is('accepted').map(&:id)
          quotation_request_ids = current_user.incoming_quotation_requests.pluck(:classified_ad_id) + current_user.outgoing_quotation_requests.pluck(:classified_ad_id)
          classified_ads = ClassifiedAd.where(id: (authorized_classified_ad_ids + quotation_request_ids - classified_ids_to_remove)).updated_desc
        else
          classified_ads = Array.new()
        end
      else
        classified_ads = Array.new()
      end
      render json: classified_ads, status: :ok, each_serializer: ClassifiedAdListSerializer
		else
			render json: nil, status: :unauthorized
		end
	end

	def create
    if signed_in?
      classified = ClassifiedAd.new(user: current_user)
      if classified.update_attributes(classified_params)

        render json: classified, status: :created

      else
        render json: classified.errors, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def show
    if params.has_key?(:public)
      ad = ClassifiedAd.find(params[:id])
      if ad.present?
        render json: ad, status: :ok, serializer: PublicClassifiedAdSerializer
      else
        render json: nil, status: :not_found
      end
    elsif signed_in?
      ad = ClassifiedAd.find(params[:id])
      if ad.present?
        if ad.user.id == current_user.id || (ad.id.in? current_user.authorized_classified_ad_ids)
          render json: ad, status: :ok
        else
          render json: nil, status: :unauthorized
        end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def update
    if signed_in?
      classified_ad = ClassifiedAd.find_by(id: params[:id])
      if classified_ad.present?
        if classified_ad.user.id == current_user.id
          if params.has_key?(:photo) && params[:photo].present?
            photo = ClassifiedAdPhoto.create(classified_ad: classified_ad, attachment: photo_params[:photo])
            if photo.present?
              classified_ad.classified_ad_photos << photo
            end
          elsif params[:status] == "publish"
            classified_ad.publish!
          elsif params[:status] == "suspend"
            classified_ad.suspend!
          elsif params[:status] == "close"
            classified_ad.close!
          elsif params[:status] == "submit"
            classified_ad.submit!
          else
            classified_ad.update_attributes(classified_params)
            if params.has_key?(:photo_ids_to_remove)
              ClassifiedAdPhoto.delete(params[:photo_ids_to_remove])
            end
          end
        elsif params[:status] == "report"
          # classified_ad.update_attribute(:reject_reason, params[:reject_reason])
          classified_ad.report! params[:reject_reason]
        elsif params.has_key?(:quotation) && current_user.is_pro?
          quotation_request = classified_ad.quotation_requests.joins(:professionals).where("quotation_requests_professionals.user_id = ?", current_user.id).first
          if !quotation_request.present?
            quotation_request = QuotationRequest.create(customer: classified_ad.user, professionals: [current_user], classified_ad: classified_ad)
          end
          if quotation_request.update_attribute(:quotation, classified_params[:quotation])
            conversation = Conversation.where(classified_ad: classified_ad).includes(:conversation_users).where(conversation_users: { user: current_user }).first
            is_new_conversation = false
            if !conversation.present?
              is_new_conversation = true
              conversation = Conversation.create(classified_ad: classified_ad)
              conversation.users << classified_ad.user
              conversation.users << current_user
            end
            system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "new_quotation", quotation_url: quotation_request.quotation.url }.to_json )
            if classified_ad.user.online
              Fiber.new do
                if is_new_conversation
                  WebsocketRails["user_#{classified_ad.user.id}"].trigger(:conversation_new, { conversation_id: conversation.id, content: system_message.content, system_generated: true, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: classified_ad.user, unread: true).count, owner: { clad_id: classified_ad.id, qr_id: quotation_request.id } })
                 else
                  WebsocketRails["user_#{classified_ad.user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: classified_ad.user, unread: true).count, owner: { clad_id: classified_ad.id, qr_id: quotation_request.id } })
                 end
              end.resume
            else
              NotificationMailer.new_quotation_email(quotation_request.id, current_user.id).deliver
            end
            render json: classified_ad, status: :ok
            return
          else
            render json: {errors: quotation_request.errors}, status: :unprocessable_entity
            return
          end
        else
          render json: nil, status: :unauthorized
          return
        end
        render json: classified_ad, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  private

  def place_is_in_range (place, address)
    place_lat_lng = Geokit::LatLng.new(place.latitude, place.longitude)
    pro_address_lat_lng = Geokit::LatLng.new(address.latitude, address.longitude)
    in_range = pro_address_lat_lng.distance_to(place_lat_lng, { units: :kms }) <= (address.action_range)
    return in_range
  end

  def photo_params
    params.permit(:photo)
  end

  def classified_params
    params.permit(
      :quotation,
      :title, 
      :description,
      :place_id,
      :start_date,
      profession_ids: []
    )
  end
end