require './lib/mailin'

class Api::V1::UsersController < ApiController

  def show
    if params[:id] == 'me'
      if signed_in?
        deal_ids = Deal.all.pluck(:id)
        deal_ids.each do |id|
          session["dp#{id}"] = 0
        end
        map_profile_ids = ProfileSponsoring.where(display_location: "sponsored_map_profile").pluck(:id)
        map_profile_ids.each do |id|
          session.delete("pmp#{id}")
        end
        me = User.includes(addresses: [:opening_hours]).find(current_user.id)
        render json: me, serializer: UserSerializer
      else
        render json: nil, status: :not_found
      end
    else
      user = User.find_by(id:params[:id]) || User.find_by(pretty_name: params[:id])
      if user.present?
        render json: user
      else
        render json: nil, status: :not_found
      end
    end
  end

  def index
    if params.has_key?(:cname)
      pros_with_name = User.pro.active.where("company_name LIKE ?", "%#{params[:cname]}%")
      render json: pros_with_name, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def create
    if AccountEmail.where(email: create_params[:email]).count > 0
      render json: nil, status: :im_used
    else
      account_email = AccountEmail.create(email: create_params[:email])
      user = User.create(first_name: create_params[:email][/[^@]+/], last_name: '')
      account = Account.create(password: create_params[:password], password_confirmation: create_params[:password_confirmation])
      account.users << user
      account.account_emails << account_email
      account.save!
      account.reload
      user.accept_referral_by_token(create_params[:email], params[:token])
      session[:current_account_id] = account.id
      user.log_signin
      render json: user, status: :created
    end
  end

  def update
    user = User.find(params[:id])
    if user.nil?
      render json: nil, status: :not_found
    else
      if signed_in? && user.id == current_user.id
        if params.has_key?(:addresses)
          place_id_from_current = Address.where(user: current_user).pluck(:place_id)
          if params[:addresses].present?
            params[:addresses].each do |address|
              address_to_update = Address.find_or_initialize_by(user: current_user, place_id: address["place_id"])
              address_to_update.action_range = address["action_range"]
              address_to_update.formatted_address = address["formatted_address"]
              address_to_update.place_id = address["place_id"]
              address_to_update.latitude = address["latitude"]
              address_to_update.longitude = address["longitude"]
              address_to_update.land_phone = address["land_phone"]
              address_to_update.mobile_phone = address["mobile_phone"]
              address_to_update.fax = address["fax"]
              if address_to_update.valid?
                address_to_update.save
                # Do update opening hours
                if address[:opening_hours]
                  address_to_update.bulk_update_opening_hours address.fetch(:opening_hours)
                else
                  address_to_update.opening_hours.delete_all
                end
                place_id_from_current.delete(address["place_id"])
                current_user.addresses << address_to_update
              else
                render json: {errors: address_to_update.errors}, status: :unprocessable_entity
                return
              end
            end
            place_id_from_current.each do |place_id|
              address = Address.find_by(place_id: place_id)
              address.destroy
            end
          end
        end
        if params.has_key?(:avatar)
          if user.update_attribute(:avatar, avatar_params[:avatar])
            render json: user, status: :ok
          else
            render json: {errors: user.errors}, status: :unprocessable_entity
          end
        elsif params.has_key?(:photo) && params[:photo].present?
          photo = UserPhoto.create(user: current_user, attachment: photo_params[:photo])
          if photo.present?
            user.user_photos << photo
            render json: nil, status: :ok
          else
            render json: {errors: photo.errors}, status: :unprocessable_entity
          end
        else
          original_newsletter = user.newsletter
          user_user_type = user.user_type
          if params.has_key?(:logo_image) && params[:logo_image].present?
            user.avatar = Base64.decode64(params[:logo_image][params[:logo_image].index(',') .. -1])
          end
          if user.update_attributes(user_params)
            if params.has_key?(:photo_ids_to_remove)
              UserPhoto.delete(params[:photo_ids_to_remove])
            end
            if !user_user_type.present? && params[:user_type].present?
              pricing = Pricing.active('bonus_signup') if params[:user_type] == 'pro'
              if pricing.present? && pricing.active?
                price_for_category = pricing.price_for_categories.find_by(pricing_category: user.primary_activity.pricing_category)
                transaction = CreditTransaction.create(user: user, credit_amount: price_for_category.credit_amount, description: "bonus_signup")
                transaction.accept!
              end
              referral = Referral.find_by(customer: user,workflow_state: "registered")
              referral.process_reward if referral.present?
            end
            user.tag_list = params[:tag_list]
            if user.save
              if params.has_key?(:newsletter) && (!user_user_type.present? || params[:newsletter] != original_newsletter)
                if update_create_user(user, params[:newsletter]) == true
                else
                  user.newsletter = original_newsletter
                  user.save
                end
              end
              render json: user, status: :ok
            else
              render json: {errors: user.errors}, status: :unprocessable_entity
            end
          else
            render json: {errors: user.errors}, status: :unprocessable_entity
          end
        end
      else
        render json: nil, status: :unauthorized
      end
    end
  end

  def get_notifications
    if signed_in?
      my_post_mentions_count = PostComment.where(post: current_user.posts, unread: true).where.not(user: current_user).count + PostUserMention.where(user: current_user, post: current_user.posts, unread: true).count
      my_mentions_count = PostUserMention.where(user: current_user, post: current_user.posts, unread: true).count + PostCommentUserMention.where(user: current_user, unread: true).count
      subscriptions = PostAuthorSubscription.where(user: current_user, unread: true ).count + PostCategorySubscription.where(user: current_user, unread: true).count
      if current_user.is_pro?
        # For classified ads
        authorized_classified_ad_ids = current_user.authorized_classified_ad_ids
        if authorized_classified_ad_ids.count > 0
          classified_ads = get_authorized_classified_ads(authorized_classified_ad_ids, params[:status_type])
          conversations = classified_ads.map { |clad| clad.conversations }
          classified_ads_notif_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations.flatten).count
        else
          classified_ads_notif_count = 0
        end
        # For direct messages
        conversations = current_user.conversations.where(classified_ad: nil)
        conversations_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations).count
        # For quotation requests
        classified_ids_to_remove = classified_ads_where_reply_is('rejected').map(&:id) + classified_ads_where_reply_is('accepted').map(&:id)
        quotation_requests = current_user.incoming_quotation_requests.where.not(quotation_request_professionals: {quotation_uid: nil}).where.not(classified_ad_id: classified_ids_to_remove)
        conversations = quotation_requests.map { |qr| qr.classified_ad.conversations  }
        quotation_requests_sent_notif_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations.flatten).count
        quotation_requests = current_user.incoming_quotation_requests.where(quotation_request_professionals: {quotation_uid: nil}).where.not(classified_ad_id: classified_ids_to_remove).updated_desc
        conversations = quotation_requests.map { |qr| qr.classified_ad.conversations  }
        quotation_requests_pending_notif_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations.flatten).count
        # For results
        # Accepted
        accepted_quotation_requests = current_user.incoming_quotation_requests.where(classified_ad_id: classified_ads_where_reply_is('accepted').map(&:id))
        conversations = accepted_quotation_requests.map { |qr| qr.classified_ad.conversations  }
        accepted_quotation_requests_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations.flatten).count
        # Rejected
        rejected_quotation_requests = current_user.incoming_quotation_requests.where(classified_ad_id: classified_ads_where_reply_is('rejected').map(&:id))
        conversations = rejected_quotation_requests.map { |qr| qr.classified_ad.conversations  }
        rejected_quotation_requests_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations.flatten).count
        render json: { classified_ads: classified_ads_notif_count, quotation_requests_pending: quotation_requests_pending_notif_count, quotation_requests_sent: quotation_requests_sent_notif_count, conversations: conversations_count, accepted: accepted_quotation_requests_count, rejected: rejected_quotation_requests_count, post_mentions_count: my_post_mentions_count, mentions_count: my_mentions_count, subscriptions: subscriptions }, status: :ok
      else
        # For quotation requests
        quotation_requests = (current_user.classified_ads.map { |clad| clad.quotation_requests }).flatten
        quotation_request_conversations = quotation_requests.map { |qr| qr.classified_ad.conversations  }
        quotation_requests_notif_count = ConversationUser.where( user: current_user, unread: true, conversation: quotation_request_conversations.flatten).count
        # For classified ads
        classified_ad_conversations = current_user.classified_ads.map { |clad| clad.conversations } - quotation_request_conversations
        classified_ads_notif_count = ConversationUser.where( user: current_user, unread: true, conversation: classified_ad_conversations.flatten).count
        # For direct messages
        conversations = current_user.conversations.where(classified_ad: nil)
        conversations_count = ConversationUser.where( user: current_user, unread: true, conversation: conversations).count
        render json: { classified_ads: classified_ads_notif_count, quotation_requests: quotation_requests_notif_count, conversations: conversations_count, post_mentions_count: my_post_mentions_count, mentions_count: my_mentions_count, subscriptions: subscriptions }, status: :ok
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def get_possible_nickname
    if signed_in?
      if params[:original_name].present?
        current_user.pretty_name = params[:original_name].parameterize
        i = 1
        while !current_user.valid? do
          if current_user.errors[:pretty_name].empty?
            break
          else
            current_user.pretty_name = params[:original_name].parameterize + i.to_s
            i += 1
          end
        end
        render json: { pretty_name: current_user.pretty_name }, status: :ok
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def change_email
    if AccountEmail.where(email: params[:email]).count > 0
      render json: nil, status: :im_used
    elsif signed_in?
      new_email = params[:email]
      old_email = params[:old_email]
      account_email = AccountEmail.find_by(email: old_email)
      if account_email.present?
        account_email.email = new_email
        account_email.save
        render json: nil, status: :ok
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def change_password
    if signed_in? && current_user.account.authenticate(params[:old_password])
      if current_user.account.update_attributes(password_params)
        render json: nil, status: :ok
      else
        render json: { errors: current_user.account.errors }, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def check_email_is_free
    if signed_in?
      if params.has_key?(:email) && params[:email].present?
        if AccountEmail.where(email: params[:email]).count == 0
          render json: nil, status: :ok
        else
          render json: nil, status: :im_used
        end
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def request_password
    if params.has_key?(:email)
      account_email = AccountEmail.where(email: params[:email]).first
      if account_email.present?
        account_email.account.send_new_password
        render json: nil, status: :no_content
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unprocessable_entity
    end
  end

  private

  def photo_params
    params.permit(:photo)
  end

  def avatar_params
    params.permit(:avatar)
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:company_name, :first_name, :last_name, :name_is_public, :user_type, :birthdate, :short_description, :long_description, :advantages, :client_references, :siret, :address, :land_phone, :mobile_phone, :website, :primary_activity_id, :secondary_activity_id, :tertiary_activity_id, :quaternary_activity_id, :place_id, :quotation, :prestation, :hourly_rate, :newsletter, :email_notifications, :pretty_name, :premium_posts, tag_list: [])
  end

  def create_params
    params.permit(:email, :password, :password_confirmation)
  end

  def update_create_user user, register
    m = Mailin.new("https://api.sendinblue.com/v2.0", Rails.application.secrets.sendinblue_api_key)

    target_list_id = JSON.parse(ENV['SENDINBLUE_LISTS'])[0]

    if user.user_type == 'pro'
      target_list_id = JSON.parse(ENV['SENDINBLUE_LISTS'])[user.primary_activity.parent_id]
    end

    if !register
      listid = []
      listid_unlink = [target_list_id]
    else
      listid = [target_list_id]
      listid_unlink = []
    end
    user_fields = { "NAME" => user.first_name, "SURNAME" => user.last_name }
    if user.user_type == 'pro'
      address = user.addresses.first.present? ? user.addresses.first.formatted_address : ""
      user_fields = user_fields.merge({ "PROFESSION" => user.primary_activity.present? ? user.primary_activity.name : "", "ETS_NAME" => user.company_name, "ADDRESS" => address })
    else
      user_fields = user_fields.merge({ "BIRTHDATE" => user.birthdate.present? ? user.birthdate.strftime("%m-%d-%Y") : "", "CITY" => user.place.place_name, "POSTAL_CODE" => user.place.postal_code })
    end
    response = m.create_update_user(user.account.account_emails.first.email, user_fields, 0, listid, listid_unlink, 0)
    result = JSON.parse(response)
    if result["code"] == "success"
      return true
    else
      return result["message"]
    end
  end

end
