class UsersFavoritePostSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :post_type,
             :category_name,
             :updated_at,
             :user_nickname,
             :user_avatar_url

  def description
    object.truncated_description
  end

  def category_name
    object.post_category.name
  end

  def user_nickname
    object.user.pretty_name
  end

  def user_avatar_url
    if object.user.avatar_uid.present?
      object.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

end
