# == Schema Information
#
# Table name: users_favorite_professionals
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  professional_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class UsersFavoriteProfessionalSerializer < BaseSerializer

  attributes :id,
             :display_name,
             :avatar_url,
             :primary_activity,
             :secondary_activity,
             :tertiary_activity,
             :quaternary_activity,
             :addresses,
             :first_login,
             :pretty_name

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

  def quaternary_activity
    if object.is_pro? && object.quaternary_activity.present?
      object.quaternary_activity.name
    else
      nil
    end
  end

  def tertiary_activity
    if object.is_pro? && object.tertiary_activity.present?
      object.tertiary_activity.name
    else
      nil
    end
  end

  def secondary_activity
    if object.is_pro? && object.secondary_activity.present?
      object.secondary_activity.name
    else
      nil
    end
  end

  def primary_activity
    if object.is_pro?
      object.primary_activity.name
    else
      nil
    end
  end

  def first_login
    object.first_login.to_i
  end

end
