class SearchProSerializer < BaseSerializer

  attributes :id,
             :text,
             :logo_url

  def text
  	object.company_name
  end

  def logo_url
    if object.avatar_uid.present?
      object.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

end