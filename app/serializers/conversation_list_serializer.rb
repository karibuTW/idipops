class ConversationListSerializer < BaseSerializer

  attributes :id,
             :updated_at,
             :unread,
             :user

  has_many :users, serializer: UserCardSerializer

  def user
    object.users.each do |u|
      return UserCardSerializer.new(u).serializable_hash if u.id != current_user.id
    end
  end

end