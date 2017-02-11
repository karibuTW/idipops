class UsersCombinedFavoriteDealSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :favorite_type,
             :created_at,
             :user_name,
             :user_avatar_url,
             :user_type,
             :pro_pretty_name,
             :favorited,
             :deal_id

  def description
    object.deal.description
  end

  def user_name
    object.deal.user.display_name
  end

  def user_avatar_url
    if object.deal.user.avatar_uid.present?
      object.deal.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def favorite_type
    "deal"
  end

  def title
    object.deal.tagline
  end

  def user_type
    "pro"
  end

  def pro_pretty_name
    object.deal.user.pretty_name
  end

  def favorited
    true
  end

  def deal_id
    object.deal.id
  end

end
