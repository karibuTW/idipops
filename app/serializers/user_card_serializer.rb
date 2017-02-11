class UserCardSerializer < BaseSerializer

  attributes :id,
             :display_name,
             :avatar_url,
             :activity,
             :place_name,
             :first_login,
             :pretty_name,
             :user_type

  def avatar_url
    if object.avatar_uid.present?
      object.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def display_name
    object.display_name
  end

  def activity
    if object.is_pro?
      object.primary_activity.name
    else
      nil
    end
  end

  def place_name
    if object.is_pro?
      nil
    else
      object.place.place_name
    end
  end

  def first_login
    object.first_login.to_i
  end

  def user_type
    object.user_type
  end

end