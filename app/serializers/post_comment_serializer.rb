class PostCommentSerializer < BaseSerializer

  attributes  :id,
              :content,
              :updated_at,
              :user_avatar_url,
              :user_nickname,
              :liked,
              :num_of_likes,
              :favorite_post_comment_id,
              :user_mentions

  def user_avatar_url
    if object.user.avatar_uid.present?
      object.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def user_nickname
  	object.user.pretty_name
  end

  def liked
    current_user.present? && object.users_favorite_post_comments.where(user: current_user).count > 0
  end

  def num_of_likes
    object.users_favorite_post_comments.count
  end

  def favorite_post_comment_id
    if current_user.present? && object.users_favorite_post_comments.where(user: current_user).count > 0
      object.users_favorite_post_comments.where(user: current_user).first.id
    else
      nil
    end
  end

  def user_mentions
    users = Array.new()
    object.post_comment_user_mentions.each do |mention|
      if mention.user.user_type == 'pro'
        users << mention.user.pretty_name
      end
    end
    users
  end

end
