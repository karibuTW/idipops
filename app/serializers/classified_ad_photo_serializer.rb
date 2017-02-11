class ClassifiedAdPhotoSerializer < BaseSerializer

  attributes :id,
             :attachment_url

  def attachment_url
    if object.attachment_uid.present?
      object.attachment.remote_url(expires: 1.hour.from_now)
    else
      nil
    end
  end

end
