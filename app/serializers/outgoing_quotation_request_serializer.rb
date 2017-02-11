class OutgoingQuotationRequestSerializer < BaseSerializer

	attributes 	:id,
              :title,
              :description,
							:customer_display_name,
	            :customer_avatar_url,
              :customer_first_login,
              :place,
              :classified_ad_id,
	            :created_at,
              :updated_at,
              :specific_fields,
              :num_of_quotations,
              :num_of_requests,
              :has_quotation,
              :template_id,
              :start_date

  def template_id
    object.professionals.first.primary_activity.quotation_request_template_id
  end

  def start_date
    object.classified_ad.start_date
  end

  def title
    object.classified_ad.title
  end

  def description
    object.classified_ad.description
  end

	def customer_display_name
  	object.customer.display_name
  end

  def customer_first_login
    object.customer.first_login.to_i
  end

  def customer_avatar_url
  	if object.customer.avatar_uid.present?
      object.customer.avatar.remote_url(expires: 1.hour.from_now)
    else
      'uneon-face.svg'
    end
  end

  def place
    object.classified_ad.place
  end

  def classified_ad_id
    object.classified_ad.id
  end

  def has_quotation
    if current_user.is_pro?
      object.quotation_request_professionals.where(user_id: current_user.id).where.not(quotation_uid: nil).count > 0
    else
      false
    end
  end

  def num_of_quotations
    object.quotation_request_professionals.where.not(quotation_uid: nil).count
  end

  def num_of_requests
    object.quotation_request_professionals.count
  end

end