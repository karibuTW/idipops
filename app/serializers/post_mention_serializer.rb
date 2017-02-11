class PostMentionSerializer < BaseSerializer

  attributes  :id,
              :title,
		          :content,
              :user_nickname,
              :user_avatar_url,
              :category_name,
              :unread_count

  def title
    object.title
  end

  def content
    object.truncated_description
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

  def category_name
    object.post_category.name
  end

  def unread_count
    if current_user.present?
      PostUserMention.where(user: current_user, post: object, unread: true).count
    else
      0
    end
  end

end