class UsersCombinedFavoriteProfessionalSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :favorite_type,
             :addresses,
             :created_at,
             :user_name,
             :user_avatar_url,
             :user_type,
             :pro_pretty_name,
             :favorited,
             :pro_id

  def user_avatar_url
    if object.favorite_professional.avatar_uid.present?
      object.favorite_professional.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def user_name
    object.favorite_professional.display_name
  end

  def title
    if object.favorite_professional.is_pro?
      object.favorite_professional.primary_activity.name
    else
      nil
    end
  end

  def favorite_type
    "pro"
  end

  def description
    object.favorite_professional.short_description
  end

  def addresses
    object.favorite_professional.addresses
  end

  def user_type
    "pro"
  end

  def pro_pretty_name
    object.favorite_professional.pretty_name
  end

  def favorited
    true
  end

  def pro_id
    object.favorite_professional.id
  end

end
