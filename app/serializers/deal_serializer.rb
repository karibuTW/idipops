class DealSerializer < BaseSerializer

  attributes :id,
             :tagline,
             :description,
             :start_date,
             :end_date,
             :list_image_url,
             :featured_image_url,
             :professional_id,
             :pro_pretty_name,
             :logo_url,
             :company_name,
             :addresses,
             :balance,
             :status,
             :promotions,
             :promotion_tag_list,
             :favorited,
             :num_of_favorited,
             :favorite_deal_id

  has_many :addresses
  # def addresses
  #   puts object.addresses.inspect
  #   object.addresses.map do |address|
  #     puts address.inspect
  #     AddressSerializer.new(address)
  #   end
  # end

  def promotion_tag_list
    if object.deal_promotions.count > 0
      return object.deal_promotions.first.tags.map(&:name)
    else
      Array.new
    end
  end

  def promotions
    promotions = Hash.new
    if current_user == object.user
      object.deal_promotions.each { |promotion| promotions[promotion.display_location] = promotion.remaining_impressions }
    else
      promotions
    end
    return promotions
  end

  def balance
    if current_user == object.user
      object.user.balance
    else
      nil
    end
  end

  def status
    if object.start_date.past?
      if object.end_date.past?
        return "past"
      else
        return "current"
      end
    else
      return "future"
    end
  end

  def tagline
    object.tagline.gsub(/(?:f|ht)tps?:\/[^\s]+/, '(lien supprimé)').gsub(/www\.[^\s]+/, '(lien supprimé)')
  end

  def description
    object.description.gsub(/(?:f|ht)tps?:\/[^\s]+/, '(lien supprimé)').gsub(/www\.[^\s]+/, '(lien supprimé)')
  end

  def company_name
  	object.user.company_name
  end

  def pro_pretty_name
    object.user.pretty_name
  end

  def list_image_url
  	if object.list_image_uid.present?
      Dragonfly.app.fetch(object.list_image_uid).thumb('200x160#').url
    else
      nil
    end
  end

  def featured_image_url
    if object.featured_image_uid.present?
      Dragonfly.app.fetch(object.featured_image_uid).thumb('1024x576#').url
    else
      nil
    end
  end

  def company_name
    object.user.company_name
  end

  # def addresses
  #   object.user.addresses
  # end

  def logo_url
    if object.user.avatar_uid.present?
      object.user.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def professional_id
    object.user.id
  end

  def favorited
    current_user.present? && object.users_favorite_deals.where(user: current_user).count > 0
  end

  def num_of_favorited
    object.users_favorite_deals.count
  end

  def favorite_deal_id
    if current_user.present? && object.users_favorite_deals.where(user: current_user).count > 0
      object.users_favorite_deals.where(user: current_user).first.id
    else
      nil
    end
  end

end
