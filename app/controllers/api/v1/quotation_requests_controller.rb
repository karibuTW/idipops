class Api::V1::QuotationRequestsController < ApiController
	def create
		if signed_in?
			professional = User.find(params[:professional_id])
			if professional.present? && params.has_key?(:added_pros)
				professionals = [professional]
				if params.has_key?(:added_pros) && params[:added_pros].present?
					params[:added_pros].each do |pro|
						professionals << User.find(pro[:id])
					end
				end
	      classified = ClassifiedAd.new(user: current_user, profession_ids: professional.profession_ids, workflow_state: params[:public] ? 'pending' : 'private')
	      if classified.update_attributes(classified_ad_params)
		      quotation = QuotationRequest.create(customer: current_user, professionals: professionals, classified_ad: classified)
		      if quotation.update_attributes(quotation_params)
		      	professionals.each do |pro|
			      	create_conversation_for_pro(pro, classified, quotation)
			      end
		        render json: quotation, status: :created, serializer: OutgoingQuotationRequestSerializer
		      else
		      	render json: quotation.errors, status: :unprocessable_entity
		      end
	      else
	        render json: classified.errors, status: :unprocessable_entity
	      end
	    else
	    	render json: nil, status: :not_found
	    end
    else
      render json: nil, status: :unauthorized
    end
	end

	def update
		if signed_in?
      quotation_request = QuotationRequest.find(params[:id])
      if quotation_request.present?
        if current_user.is_pro?
        	if params.has_key?(:quotation)
	        	quotation_request_professional = quotation_request.quotation_request_professionals.where(user_id: current_user.id).first
	          if quotation_request_professional.update_attribute(:quotation, quotation_params[:quotation])
	          	conversation = Conversation.where(classified_ad: quotation_request.classified_ad).includes(:conversation_users).where(conversation_users: { user: current_user }).first
	          	is_new_conversation = false
	          	if !conversation.present?
	          		is_new_conversation = true
		          	conversation = Conversation.create(classified_ad: quotation_request.classified_ad)
		            conversation.users << quotation_request.classified_ad.user
		            conversation.users << current_user
		          end
	            system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "new_quotation", quotation_url: quotation_request_professional.quotation.url }.to_json )
	            if quotation_request.classified_ad.user.online
		          	Fiber.new do
			            if is_new_conversation
			              WebsocketRails["user_#{quotation_request.classified_ad.user.id}"].trigger(:conversation_new, { conversation_id: conversation.id, content: system_message.content, system_generated: true, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: quotation_request.classified_ad.user, unread: true).count, owner: { clad_id: quotation_request.classified_ad.id, qr_id: quotation_request.id } })
					         else
					         	WebsocketRails["user_#{quotation_request.classified_ad.user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: quotation_request.classified_ad.user, unread: true).count, owner: { clad_id: quotation_request.classified_ad.id, qr_id: quotation_request.id } })
					         end
			          end.resume
			        else
			        	NotificationMailer.new_quotation_email(quotation_request.id, current_user.id).deliver
			        end
	            render json: quotation_request, status: :ok, serializer: OutgoingQuotationRequestSerializer
	          else
	            render json: {errors: quotation_request.errors}, status: :unprocessable_entity
	          end
	        elsif params.has_key?(:mark_read)
	        	ConversationUser.where( user: current_user, unread: true, conversation: quotation_request.classified_ad.conversations).each do |conversation_user|
          		conversation_user.conversation.mark_read(current_user)
          	end
          	render json: nil, status: :ok
          end
        elsif params.has_key?(:pro_ids) && !current_user.is_pro?
          params[:pro_ids].each do |pro_id|
          	pro = User.find(pro_id)
          	quotation_request.professionals << pro
          	create_conversation_for_pro(pro, quotation_request.classified_ad, quotation_request)
          end
          if quotation_request.save
          	render json: nil, status: :ok
          else
          	render json: {errors: quotation_request.errors}, status: :unprocessable_entity
          end
        else
	        render json: nil, status: :unauthorized
        end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
	end

	def index
		if signed_in?
			quotation_requests = Array.new
			if current_user.is_pro?
				classified_ids_to_remove = classified_ads_where_reply_is('rejected').map(&:id) + classified_ads_where_reply_is('accepted').map(&:id)
				if params.has_key?(:filter)
					if params[:filter] == 'replied'
						quotation_requests = current_user.incoming_quotation_requests.where.not(quotation_request_professionals: {quotation_uid: nil}).where.not(classified_ad_id: classified_ids_to_remove).updated_desc
					else
						quotation_requests = current_user.incoming_quotation_requests.where(quotation_request_professionals: {quotation_uid: nil}).where.not(classified_ad_id: classified_ids_to_remove).updated_desc
					end
				else
					quotation_requests = current_user.incoming_quotation_requests.where(classified_ad_id: classified_ids_to_remove).updated_desc
				end
				render json: quotation_requests, status: :ok, each_serializer: IncomingQuotationRequestListSerializer
			else
				if params.has_key?(:filter)
					if params[:filter] == 'replied'
						quotation_requests = current_user.outgoing_quotation_requests.joins(:quotation_request_professionals).where.not(quotation_request_professionals: {quotation_uid: nil}).updated_desc
					else
						quotation_requests = current_user.outgoing_quotation_requests.joins(:quotation_request_professionals).where(quotation_request_professionals: {quotation_uid: nil}).updated_desc
					end
				else
					quotation_requests = current_user.outgoing_quotation_requests.updated_desc
				end
				render json: quotation_requests, status: :ok, each_serializer: OutgoingQuotationRequestListSerializer
			end
		else
			render json: nil, status: :unauthorized
		end
	end

  def show
    if signed_in?
      qr = QuotationRequest.find(params[:id])
      if qr.present?
      		if qr.customer == current_user
		        render json: qr, status: :ok, serializer: OutgoingQuotationRequestSerializer
		      elsif current_user.in? qr.professionals
		      	if qr.classified_ad.id.in? current_user.authorized_classified_ad_ids
			        render json: qr, status: :ok, serializer: IncomingQuotationRequestSerializer
			      else
			      	pricing = Pricing.active('classified_ad_unlock')
			      	if pricing.present? && pricing.active?
				        price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
				        if price_for_category.present?
				          price = price_for_category.credit_amount
				          if price == 0
				          	transaction = CreditTransaction.create(user: current_user, credit_amount: 0, description: "classified_ad_unlock")
		                transaction.accept!
		                authorization = Authorization.create(credit_transaction: transaction, classified_ad: qr.classified_ad)
		                render json: qr, status: :ok, serializer: IncomingQuotationRequestSerializer
				          end
				        end
				      end
				      if !authorization.present?
				      	render json: nil, status: :unauthorized
				      end
				    end
		      else
		      	render json: nil, status: :unauthorized
		      end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

	def classified_ad_params
		params.permit(
      :title, 
      :description,
      :place_id,
      :start_date
    )
	end

  def quotation_params
    params.permit(
      :specific_fields,
      :quotation
    )
  end

  private

  def create_conversation_for_pro pro, classified, quotation
  	conversation = Conversation.create(classified_ad: classified)
		conversation.users << pro
		conversation.users << current_user
		system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "new_quotation_request", quotation_request_id: quotation.id }.to_json )
		if pro.online
			Fiber.new do
				WebsocketRails["user_#{pro.id}"].trigger(:conversation_new, { conversation_id: conversation.id, content: system_message.content, system_generated: true, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: pro, unread: true).count, owner: { clad_id: classified.id, qr_id: quotation.id } })
			end.resume
		else
			NotificationMailer.quotation_request_email(quotation.id, pro.id).deliver
		end
	end
end