class SubscribedPostListSerializer < PostListSerializer

  def unread_count
    0
    # if current_user.present?
    #   total_unread = PostAuthorSubscription.where(user: current_user, author: object.user, unread: true ).where('last_read_at <= ?', object.created_at).count + PostCategorySubscription.where(user: current_user, post_category: object.post_category, unread: true).where('last_read_at <= ?', object.created_at).count
    #   total_unread > 1 ? 1 : total_unread
    # else
    #   0
    # end
  end

end