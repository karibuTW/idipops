class PostSerializer < PostListSerializer

  attributes  :description,
		          :status,
              :user_mentions,
              :sponsored_impressions,
              :profession_id,
              :profession_name

  has_many :post_photos

  def status
    object.current_state.name
  end

  def description
    object.description
  end

  def user_mentions
    users = Array.new()
    object.post_user_mentions.each do |mention|
      if mention.user.user_type == 'pro'
        users << mention.user.pretty_name
      end
    end
    users
  end

  def sponsored_impressions
    PostSponsoring.where(post: object, display_location: "sponsored_post").sum(:remaining_impressions)
  end

  def profession_id
    linked_profession.id
  end

  def profession_name
    linked_profession.name
  end

  private

  def linked_profession
    @linked_profession ||= object.post_category.professions.first
  end
end