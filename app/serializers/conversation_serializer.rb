# == Schema Information
#
# Table name: conversations
#
#  id               :integer          not null, primary key
#  classified_ad_id :integer
#  workflow_state   :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ConversationSerializer < BaseSerializer

  attributes 	:id,
				:user,
				:quotation_url,
        :status

  has_many :messages

  def user
    object.users.each do |u|
      return UserCardSerializer.new(u).serializable_hash if u.id != current_user.id
    end
  end

  def quotation_url
    if !object.classified_ad.present?
      return nil
    end
    quotation_request = object.classified_ad.quotation_requests.joins(:professionals).where("user_id in (?)", object.users.pluck(:id)).first
  	if quotation_request.present?
      quotation_request_professional = quotation_request.quotation_request_professionals.where(professional: object.users).first
      if quotation_request_professional.quotation_uid.present?
        Dragonfly.app.fetch(quotation_request_professional.quotation_uid).url
      end
    else
    	return nil
    end
  end

  def status
    object.current_state.name
  end

end
