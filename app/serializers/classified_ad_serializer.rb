class ClassifiedAdSerializer < ClassifiedAdListSerializer

  attributes :start_date,
             :created_at,
             :user_first_login,
             :professions,
             :reject_reason,
             :has_quotation

  has_one :place
  has_many :classified_ad_photos

  def reject_reason
    if object.user.id == current_user.id && object.rejected?
      object.reject_reason
    else
      nil
    end
  end

  def has_quotation
    if current_user.is_pro?
      quotation_request = object.quotation_requests.joins(:quotation_request_professionals).where(quotation_request_professionals: {professional: current_user}).first
      quotation_request.present? && quotation_request.quotation_request_professionals.where(user_id: current_user.id).where.not(quotation_uid: nil).count > 0
    else
      false
    end
  end

  def user_first_login
    object.user.first_login.to_i
  end

  def professions
    simple_professions = Array.new()
    object.professions.each do |profession|
      simple_professions << { id: profession.id, name: profession.name }
    end
    return simple_professions
  end

end