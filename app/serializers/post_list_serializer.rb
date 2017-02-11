class PostListSerializer < BaseSerializer
  root 'post'

  attributes :id,
             :title,
             :slug,
             :description,
             :updated_at,
             :created_at,
             :user_nickname,
             :user_avatar_url,
             :featured_image_url,
             :created_at,
             :user_type,
             :category_id,
             :category_name,
             :post_type,
             :num_of_views,
             :author_subscribed,
             :category_subscribed,
             :num_of_subscriptions,
             :category_subscription_id,
             :author_subscription_id,
             :favorited,
             :num_of_favorited,
             :favorite_post_id,
             :editable,
             :unread_count

  def category_id
    object.post_category.id
  end

  def category_name
    object.post_category.name
  end

  def user_type
    object.user.user_type
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

  def description
    object.truncated_description
  end

  def featured_image_url
    if object.featured_image_uid.present?
      object.featured_image.remote_url
    else
      nil
    end
  end

  def num_of_views
    object.post_views.count
  end

  def author_subscribed
    current_user.present? && object.user.post_subscribers.where(user: current_user).count > 0
  end

  def category_subscribed
    current_user.present? && object.post_category.users.include?(current_user)
  end

  def num_of_subscriptions
    object.user.post_subscribers.count
  end

  def category_subscription_id
    if current_user.present? && object.post_category.users.include?(current_user)
      object.post_category.post_category_subscriptions.where(user: current_user).first.id
    else
      nil
    end
  end

  def author_subscription_id
    if current_user.present? && object.user.post_subscribers.where(user: current_user).count > 0
      object.user.post_subscribers.where(user: current_user).first.id
    else
      nil
    end
  end

  def favorited
    current_user.present? && object.users_favorite_posts.where(user: current_user).count > 0
  end

  def num_of_favorited
    object.users_favorite_posts.count
  end

  def favorite_post_id
    if current_user.present? && object.users_favorite_posts.where(user: current_user).count > 0
      object.users_favorite_posts.where(user: current_user).first.id
    else
      nil
    end
  end

  def editable
    object.created_at > 2.days.ago
  end

  def unread_count
    if current_user.present?
      PostComment.where(post: object, unread: true).where.not(user: current_user).count + PostUserMention.where(user: current_user, post: object, unread: true).count
       # + PostCommentUserMention.where(user: current_user, post_comment: object.post_comments, unread: true).count
    else
      0
    end
  end

end