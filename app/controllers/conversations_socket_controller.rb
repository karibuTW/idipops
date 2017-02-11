class ConversationsSocketController < WebsocketRails::BaseController
  def initialize_session
    # connected_users will store the connected users ID
    # User.update_all(online: false)
    controller_store[:connected_users] = Hash.new(0)
  end

  def post_message
  	if signed_in?
      # find or create the conversation
      conversation = nil
      is_new_conversation = false
      if message['message'].present? && message['message']['conversation_id'].present?
        # message for existing conversation
        conversation = Conversation.find_by(id: message['message']['conversation_id']);
      else
        # message for new conversation
        if message['clad_id'].present?
          classified_ad = ClassifiedAd.find(message['clad_id'])
          # We should check that classified_ad.user is not current_user and return an error if it is the case
          if classified_ad.present? && classified_ad.user != current_user
            conversation = classified_ad.conversations.joins(:conversation_users).where(conversation_users: {user: current_user}).first
            # conversation = classified_ad.user.conversations.where( id: current_user.conversations.pluck(:id) ).first
            if !conversation.present?
              is_new_conversation = true
              conversation = Conversation.create(classified_ad: classified_ad)
              conversation.users << current_user # add the message poster to this conversation
              conversation.users << classified_ad.user # add the classified starter to this conversation
            end
          end
        elsif message['user_id'].present?
          other_user = User.find_by(pretty_name: message['user_id']) || User.find(message['user_id'])
          if other_user.present?
            conversation = other_user.conversations.where( classified_ad: nil, id: current_user.conversations.pluck(:id) ).first
            if !conversation.present?
              is_new_conversation = true
              conversation = Conversation.create
              conversation.users << current_user # add the message poster to this conversation
              conversation.users << other_user # add the target user to this conversation
            end
          end
        end
      end
      # add the message
      if conversation.present? && conversation.users.include?(current_user)
        new_message = Message.create(conversation: conversation, user: current_user, content: message['message']['content'])
        if new_message.present?
        	online_users = get_online_users_ids
          owner = { clad_id: nil, qr_id: nil }
          if conversation.classified_ad.present?
            quotation_request = conversation.classified_ad.quotation_requests.joins(:professionals).where("user_id in (?)", conversation.users.pluck(:id)).first
            if quotation_request.present?
              owner[:qr_id] = quotation_request.id
            end
            owner[:clad_id] = conversation.classified_ad.id
          end
          
          if is_new_conversation
          	conversation.users.each { |user|
          		if current_user.id == user.id || online_users.include?(user.id)
                Fiber.new do
		              WebsocketRails["user_#{user.id}"].trigger(:conversation_new, { conversation_id: conversation.id, content: new_message.content, from_user: current_user.display_name, from_self: current_user == user, unread_conversations_count: ConversationUser.where( user: user, unread: true).count, owner: owner })
                end.resume
	            elsif current_user != user
	            	notify_by_email user, new_message, conversation
	            end
            }
          else
          	conversation.users.each { |user|
          		if current_user.id == user.id || online_users.include?(user.id)
                Fiber.new do
	            		WebsocketRails["user_#{user.id}"].trigger(:message_new, { conversation_id: conversation.id, message: new_message, from_user: current_user.display_name, from_self: current_user == user, unread_conversations_count: ConversationUser.where( user: user, unread: true).count, owner: owner })
                end.resume
          		elsif current_user != user
	            	notify_by_email user, new_message, conversation
            	end
          	}
          end
          
          trigger_success status: :created, id: conversation.id
        else
          trigger_failure errors: new_message.errors, status: :unprocessable_entity
        end
      else
        trigger_failure status: :not_found
      end

    else
      trigger_failure status: :unauthorized
    end
  end

  def conversation_read
  	user = User.find_by( id: message['user_id'] )
  	conversation = Conversation.find_by( id: message['conversation_id'] )
  	if user.present?
      if conversation.present?
        conversation.mark_read(user)
      end
      count = ConversationUser.where( user: user, unread: true).count
      Fiber.new do
        begin
          WebsocketRails["user_#{user.id}"].trigger(:conversation_read_update, { count: count})
        rescue
        end
        trigger_success
          # trigger_success new_count: ConversationUser.where( user: user, unread: true).count
      end.resume
  	end
  end

  def watch_users_status
  	if signed_in?
  		online_users = get_online_users_ids
  		watched_online_users = Array.new
  		connection_store.clear
      if message['user_ids'].present?
  	  	message['user_ids'].each { |user_id|
  	  		connection_store[user_id] = current_user.id
  	  		if online_users.include? user_id
  	  			watched_online_users << user_id
  	  		end
  	  	}
      end
	  	send_users_online_status_update watched_online_users
		end
  end

  def is_typing
    if signed_in?
      conversation = Conversation.find_by( id: message['conversation_id'] )
      if conversation.present?
        other_user = nil
        conversation.users.each { |user|
          other_user = user if user.id != current_user.id
        }
        Fiber.new do
          WebsocketRails["user_#{other_user.id}"].trigger(:user_is_typing, { conversation_id: conversation.id, is_typing: message['is_typing'] })
          trigger_success
        end.resume
      else
        trigger_failure status: :not_found
      end
    end
  end

  def user_connected
  	if signed_in?
  		# if controller_store[:connected_users].index(current_user.id) == nil
		  # 	controller_store[:connected_users] << current_user.id
		  # end
      controller_store[:connected_users][current_user.id] = controller_store[:connected_users][current_user.id] + 1;
      current_user.update_columns(online: true)
	  	users_watching_me = get_users_watching_me
	  	users_watching_me.each { |user_id|
        Fiber.new do
  	  		WebsocketRails["user_#{user_id}"].trigger(:user_status_connected, { user_id: current_user.id })
        end.resume
	  	}
      trigger_success #needed?
    else
      connection.close!
		end
  end

  def user_disconnected
  	if signed_in?
	  	# controller_store[:connected_users].delete current_user.id
      controller_store[:connected_users][current_user.id] = controller_store[:connected_users][current_user.id] - 1;
      if controller_store[:connected_users][current_user.id] <= 0
        controller_store[:connected_users][current_user.id] = 0
        current_user.update_columns(online: false)
  	  	users_watching_me = get_users_watching_me
        if users_watching_me.present?
    	  	users_watching_me.each { |user_id|
            Fiber.new do
      	  		WebsocketRails["user_#{user_id}"].trigger(:user_status_disconnected, { user_id: current_user.id })
            end.resume
    	  	}
        end
      end
		end
  end

  private

  	def notify_by_email user, message, conversation
    	cu = ConversationUser.where( user: user, conversation: conversation ).first
    	if !cu.notified
	  		NotificationMailer.new_message_email(current_user.id, user.id, message.id).deliver
	    	cu.notified = true
	    	cu.save
	    end
    end

  	def get_users_watching_me
  		connection_store.collect_all(current_user.id).compact
  	end

  	def get_online_users_ids
  		# online_users = controller_store.collect_all(:connected_users)
  		# online_users.flatten!.compact
      online_users = controller_store[:connected_users].select { |user_id, count|
        count > 0
      }
      return online_users
  	end

  	def send_users_online_status_update online_users
  		WebsocketRails["user_#{current_user.id}"].trigger(:users_status_updates, { users_id: online_users })
  	end

		def current_user
			@_current_user ||= session[:current_account_id] && User.where(account_id: session[:current_account_id]).first
		end

		def signed_in?
			!!current_user
		end
end