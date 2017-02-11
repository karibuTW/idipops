class UsersCombinedFavoritePostSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :favorite_type,
             :category_name,
             :created_at,
             :user_name,
             :user_avatar_url,
             :user_type,
             :favorited,
             :post_id

  def description
    object.post.truncated_description
  end

  def category_name
    object.post.post_category.name
  end

  def user_name
    object.post.user.pretty_name
  end

  def user_avatar_url
    if object.post.user.avatar_uid.present?
      object.post.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def favorite_type
    "post"
  end

  def title
    object.post.title
  end

  def user_type
    object.post.user.user_type
  end

  def favorited
    true
  end

  def post_id
    object.post.id
  end

end
