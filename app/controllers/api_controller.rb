class ApiController < ApplicationController

  include ActionController::Serialization # fix for using active-model-serializer in production environment
  
  # protect_from_forgery with: :null_session
  helper_method :current_user, :signed_in?
  serialization_scope :view_context

  # before_filter :slow_down_api_request
  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected

  def get_shortest_distance_from_pro (pro, lat_lng)
    shortest = 100000
    pro.addresses.each do |address|
      distance = lat_lng.distance_to(Geokit::LatLng.new(address.latitude, address.longitude), {units: :kms})
      if distance <= address.action_range && distance < shortest
        shortest = distance
      end
    end
    if shortest == 100000
      shortest = -1
    end
    return shortest
  end

  def get_distance_from_address (address, lat_lng)
    distance = lat_lng.distance_to(Geokit::LatLng.new(address.latitude, address.longitude), {units: :kms})
    if distance <= address.action_range
      return distance
    else
      return -1
    end
  end

  def get_authorized_classified_ads authorized_classified_ad_ids, status_type
    rejected_ad_ids = Array.new()
    if status_type.present?
      classified_ads = classified_ads_where_reply_is(status_type)
    else
      rejected_ad_ids = classified_ads_where_reply_is('rejected').map(&:id)
      qr_ids = current_user.incoming_quotation_requests.pluck(:classified_ad_id)
      authorized_classified_ad_ids = authorized_classified_ad_ids - rejected_ad_ids - qr_ids
      classified_ads = ClassifiedAd.with_published_state.where(id: authorized_classified_ad_ids).updated_desc
    end
    return classified_ads
  end

  def classified_ads_where_reply_is (status)
    if status == 'accepted'
      conversations = Conversation.with_accepted_state.includes(:conversation_users).where(conversation_users: { user: current_user })
    elsif status == 'rejected'
      conversations = Conversation.with_rejected_state.includes(:conversation_users).where(conversation_users: { user: current_user })
    else
      conversations = Conversation.includes(:conversation_users).where(conversation_users: { user: current_user })
    end
    conversations.order(updated_at: :desc).map(&:classified_ad)
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def slow_down_api_request
    sleep 0.5
  end

end