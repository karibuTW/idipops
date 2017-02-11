class Api::V1::ConversationsController < ApiController

  def index
    if signed_in?
      if params.has_key?(:cl_ad_id)
        classified_ad = ClassifiedAd.find(params[:cl_ad_id])
        if classified_ad
          conversations = current_user.conversations.where(classified_ad: classified_ad)
          conversations = conversations.includes(:conversation_users).where(conversation_users: { user: current_user }).select("conversations.*, conversation_users.unread")
          conversations = conversations.order(updated_at: :desc)
          # .includes(users: [:location])
          render json: conversations, status: :ok, each_serializer: ConversationListSerializer
        else
          render json: nil, status: :not_found
        end
      else
        conversations = current_user.conversations.where(classified_ad: nil)
        conversations = conversations.includes(:conversation_users).where(conversation_users: { user: current_user }).select("conversations.*, conversation_users.unread")
        conversations = conversations.order(updated_at: :desc)
        # .includes(users: [:location])
        render json: conversations, status: :ok, each_serializer: ConversationListSerializer
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def show
    if signed_in?
      conversation = Conversation.find_by(id: params[:id])
      if conversation.present? && conversation.users.include?(current_user)
        conversation.mark_read(current_user)
        Fiber.new do
          WebsocketRails["user_#{current_user.id}"].trigger(:conversation_read_update, { count: ConversationUser.where( user: current_user, unread: true).count })
        end.resume
        render json: conversation, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def update
    if signed_in?
      conversation = Conversation.find_by(id: params[:id])
      if conversation.present?
        if params.has_key?(:status) && !current_user.is_pro?
          Fiber.new do
            if params[:status] == "accept"
              # conversation.classified_ad.conversations.each do |conversation_to_reject|
              #   if conversation != conversation_to_reject
              #     conversation_to_reject.reject!
              #     other_user = conversation_to_reject.users.where.not(id: current_user.id).first
              #     system_message = Message.create(conversation: conversation_to_reject, user: current_user, system_generated: true, content: { type: "offer_rejected", reason: params[:reason] }.to_json )
              #     WebsocketRails["user_#{other_user.id}"].trigger(:message_new, { conversation_id: conversation_to_reject.id, message: system_message, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: other_user, unread: true).count, owner: { clad_id: conversation_to_reject.classified_ad.id, qr_id: nil } })
              #   end
              # end
              conversation.accept!
              # conversation.classified_ad.close!
              other_user = conversation.users.where.not(id: current_user.id).first
              system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "offer_accepted", reason: params[:reason] }.to_json )
              if other_user.online
                Fiber.new do
                  WebsocketRails["user_#{other_user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: other_user, unread: true).count, owner: { clad_id: conversation.classified_ad.id, qr_id: nil } })
                end.resume
              else
                NotificationMailer.accepted_conversation_email(conversation.id, other_user.id, params[:reason]).deliver
              end
            elsif params[:status] == "reject"
              conversation.reject!
              other_user = conversation.users.where.not(id: current_user.id).first
              system_message = Message.create(conversation: conversation, user: current_user, system_generated: true, content: { type: "offer_rejected", reason: params[:reason] }.to_json )
              if other_user.online
                Fiber.new do
                  WebsocketRails["user_#{other_user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: system_message, from_user: current_user.display_name, from_self: false, unread_conversations_count: ConversationUser.where( user: other_user, unread: true).count, owner: { clad_id: conversation.classified_ad.id, qr_id: nil } })
                end.resume
              else
                NotificationMailer.rejected_conversation_email(conversation.id, other_user.id, params[:reason]).deliver
              end
            else
              render json: nil, status: :unauthorized
              return
            end
          end.resume
          # conversation.user_reason = params[:reason]
          # if conversation.save
          render json: conversation, status: :ok
          # else
          #   render json: {errors: conversation.errors}, status: :unprocessable_entity
          # end
        else
          render json: nil, status: :unauthorized
          return
        end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end