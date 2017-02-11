class IncomingQuotationRequestSerializer < OutgoingQuotationRequestSerializer

	attributes 	:authorized

	def authorized
		object.classified_ad.id.in? current_user.authorized_classified_ad_ids
	end

end