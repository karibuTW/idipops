class PostCommentMentionSerializer < BaseSerializer

  attributes  :id,
              :title,
		          :content,
              :user_nickname,
              :user_avatar_url,
              :category_name,
              :unread_count

  def id
    object.post.id
  end
  
  def title
    object.post.title
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
    object.post.post_category.name
  end

  def unread_count
    if current_user.present?
      PostCommentUserMention.where(user: current_user, post_comment: object, unread: true).count
    else
      0
    end
  end

end