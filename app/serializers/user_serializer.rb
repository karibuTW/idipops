class UserSerializer < BaseSerializer

    has_many :addresses
    attributes :id,
             :email,
             :company_name,
             :first_name,
             :last_name,
             :name_is_public,
             :short_description,
             :long_description,
             :website,
             :user_type,
             :birthdate,
             :client_references,
             :advantages,
             :siret,
             :land_phone,
             :mobile_phone,
             :avatar_url,
             :complete,
             :first_login,
             :place,
             :primary_activity_name,
             :primary_activity_id,
             :secondary_activity_id,
             :tertiary_activity_id,
             :quaternary_activity_id,
             :hourly_rate,
             :prestation,
             :quotation,
             :tag_list,
             :balance,
             :display_name,
             :unread_conversations_count,
             :qr_template_id,
             :pretty_name,
             :newsletter,
             :email_notifications,
             :is_favorite,
             :user_rating,
             :rating,
             :token,
             :num_of_ratings,
             :user_review,
             :profile_remaining_impressions,
             :profile_map_remaining_impressions,
             :premium_posts

  has_many :user_photos

  def qr_template_id
    if object.user_type == 'pro'
      object.primary_activity.try :quotation_request_template_id
    else
      nil
    end
  end

  def primary_activity_name
    if object.user_type == 'pro'
      object.primary_activity.name
    else
      nil
    end
  end

  def profile_remaining_impressions
    profile_sponsoring = ProfileSponsoring.where(user: current_user, display_location: "sponsored_profile").first
    if profile_sponsoring.present?
      return profile_sponsoring.remaining_impressions
    else
      return 0
    end
  end

  def profile_map_remaining_impressions
    profile_sponsoring = ProfileSponsoring.where(user: current_user, display_location: "sponsored_map_profile").first
    if profile_sponsoring.present?
      return profile_sponsoring.remaining_impressions
    else
      return 0
    end
  end

  def hourly_rate
    object.hourly_rate.to_i
  end

  def num_of_ratings
    return ProRating.where(professional: object).count
  end

  def user_review
    if current_user.present? && !current_user.is_pro?
      user_review = ProReview.where(user: current_user, professional: object).first
      if user_review.present?
        return user_review.content
      else
        return nil
      end
    else
      return nil
    end
  end

  def user_rating
    if current_user.present? && !current_user.is_pro?
      user_rating = ProRating.where(user: current_user, professional: object).first
      if user_rating.present?
        return user_rating.rating
      else
        return 0
      end
    else
      return nil
    end
  end

  def is_favorite
    if current_user.present? && !current_user.is_pro?
      return current_user.favorite_professionals.pluck(:id).include? object.id
    else
      false
    end
  end

  def balance
    object.balance
  end

  def display_name
    object.display_name
  end

  def action_zones
    ActiveModel::ArraySerializer.new(object.action_zones, each_serializer: DepartementSerializer)
  end

  def email
    if current_user.present? && current_user == object
      object.account.account_emails.first.email
    else
      nil
    end
  end

  def complete
    object.complete?
  end

  def first_login
    object.first_login.to_i
  end

  def tag_list
    object.tags.map(&:name)
  end

  def avatar_url
    if object.avatar_uid.present?
      if object.is_pro?
        begin
          if object.avatar.landscape?
            border = "x#{(object.avatar.width - object.avatar.height)/2}"
          else
            border = "#{(object.avatar.height - object.avatar.width)/2}x"
          end
          object.avatar.convert("-bordercolor #FFFFFF -border #{border}").url
        rescue
          nil
        end
      else
        object.avatar.remote_url(expires: 1.hour.from_now)
      end
    else
      nil
    end
  end

  def unread_conversations_count
    ConversationUser.where( user: object, unread: true).count
  end

end
