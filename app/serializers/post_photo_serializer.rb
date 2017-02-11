class PostPhotoSerializer < BaseSerializer

  attributes :id,
             :attachment_url

  def attachment_url
    if object.attachment_uid.present?
      object.attachment.remote_url
    else
      nil
    end
  end

end
