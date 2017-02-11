class NotificationMailer < ApplicationMailer
  # default from: "from@example.com"

  def reported_post_email post_id
    @post = Post.find(post_id)
    user_to = @post.user
    if user_to.email_notifications
      @reject_reason = translate_reject_reason @post.reject_reason
      @content = convert_linebreaks @post.truncated_description
      @post_path = "#{root_url}post/#{@post.id}"
      email_to = get_email_to user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Un de vos posts a été signalé sur Idipops.com")
    end
  end

  def rejected_post_email post_id
    @post = Post.find(post_id)
    user_to = @post.user
    if user_to.email_notifications
      @reject_reason = translate_reject_reason @post.reject_reason
      @content = convert_linebreaks @post.truncated_description
      @post_path = "#{root_url}post/#{@post.id}"
      email_to = get_email_to user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Un de vos posts a été rejeté sur Idipops.com")
    end
  end

  def new_post_comment_mention_email user_to_id, post_id
    @user_to = User.find(user_to_id)
    if @user_to.email_notifications
      post = Post.find(post_id)
      @user_from = post.user
      @content = post.truncated_description
      @date = post.created_at
      @title = post.title
      @post_path = "#{root_url}post/#{post.id}"
      email_to = @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Vous avez été mentionné dans un commentaire dans le post de #{@user_from.pretty_name} sur Idipops.com")
    end
  end

  def new_post_mention_email user_to_id, post_id
    @user_to = User.find(user_to_id)
    if @user_to.email_notifications
      post = Post.find(post_id)
      @user_from = post.user
      @content = post.truncated_description
      @date = post.created_at
      @title = post.title
      @post_path = "#{root_url}post/#{post.id}"
      email_to = @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Vous avez été mentionné dans le post de #{@user_from.pretty_name} sur Idipops.com")
    end
  end

  def new_post_email user_to_id, post_id
    @user_to = User.find(user_to_id)
    if @user_to.email_notifications
      post = Post.find(post_id)
      @user_from = post.user
      @content = post.truncated_description
      @date = post.created_at
      @title = post.title
      @post_path = "#{root_url}post/#{post.id}"
      email_to = @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Nouveau post de #{@user_from.pretty_name} sur Idipops.com")
    end
  end

  def new_post_comment_email user_from_id, user_to_id, post_comment_id
    @user_to = User.find(user_to_id)
    if @user_to.email_notifications
      @user_from = User.find(user_from_id)
      post_comment = PostComment.find(post_comment_id)
      @comment = convert_linebreaks post_comment.content
      @date = post_comment.created_at
      @title = post_comment.post.title
      @post_path = "#{root_url}post/#{post_comment.post.id}"
      email_to = @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Nouveau commentaire de #{@user_from.pretty_name} sur Idipops.com")
    end
  end

  def new_message_email user_from_id, user_to_id, message_id
    @user_to = User.find(user_to_id)
    if @user_to.email_notifications
    	@user_from = User.find(user_from_id)
    	message = Message.find(message_id)
    	@content = convert_linebreaks message.content.truncate(250)
    	@date = message.created_at
    	if message.conversation.classified_ad.present?
    		@title = message.conversation.classified_ad.title
  	  	@conversation_path = "#{root_url}annonce/#{message.conversation.classified_ad.id}?conversation_id=#{message.conversation.id}"
    	else
  	  	@conversation_path = root_url + (@user_to.is_pro? ? "tableau-de-bord-pro" : "tableau-de-bord")
    	end
      email_to = get_email_to @user_to.account.account_emails.first.email
    	mail(to: email_to, subject: "Nouveau message de #{@user_from.display_name} sur Idipops.com")
    end
  end

  def quotation_request_email quotation_request_id, pro_id
    @quotation_request = QuotationRequest.find(quotation_request_id)
    @user_to = User.find(pro_id)
    if @user_to.email_notifications
      @user_from = @quotation_request.customer
      @content = convert_linebreaks @quotation_request.classified_ad.description.truncate(250)
      @title = @quotation_request.classified_ad.title
      @date = @quotation_request.created_at
      @quotation_request_path = "#{root_url}demande-de-devis/#{@quotation_request.id}"
      email_to = get_email_to @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Vous avez reçu une demande de devis sur Idipops.com")
    end
  end

  def new_quotation_email quotation_request_id, pro_id
    @quotation_request = QuotationRequest.find(quotation_request_id)
    @user_to = @quotation_request.customer
    if @user_to.email_notifications
      @user_from = User.find(pro_id)
      @content = convert_linebreaks @quotation_request.classified_ad.description.truncate(250)
      @title = @quotation_request.classified_ad.title
      @date = @quotation_request.created_at
      @quotation_request_path = "#{root_url}demande-de-devis/#{@quotation_request.id}"
      email_to = get_email_to @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Vous avez reçu un devis sur Idipops.com")
    end
  end

  def rejected_classified_ad_email classified_ad_id
  	@classified_ad = ClassifiedAd.find(classified_ad_id)
    user_to = @classified_ad.user
    if user_to.email_notifications
    	@reject_reason = translate_reject_reason @classified_ad.reject_reason
    	@content = convert_linebreaks @classified_ad.description.truncate(250)
    	@classified_ad_path = "#{root_url}annonce/#{@classified_ad.id}"
      email_to = get_email_to user_to.account.account_emails.first.email
    	mail(to: email_to, subject: "Une de vos annonces a été rejetée sur Idipops.com")
    end
  end

  def reported_classified_ad_email classified_ad_id
  	@classified_ad = ClassifiedAd.find(classified_ad_id)
    user_to = @classified_ad.user
    if user_to.email_notifications
    	@reject_reason = translate_reject_reason @classified_ad.reject_reason
    	@content = convert_linebreaks @classified_ad.description.truncate(250)
    	@classified_ad_path = "#{root_url}annonce/#{@classified_ad.id}"
      email_to = get_email_to user_to.account.account_emails.first.email
    	mail(to: email_to, subject: "Une de vos annonces a été signalée sur Idipops.com")
    end
  end

  def rejected_conversation_email conversation_id, user_id, reason
    user = User.find(user_id)
    if user.email_notifications
      @conversation = Conversation.find(conversation_id)
      @reject_reason = translate_reject_reason reason
      @content = convert_linebreaks @conversation.classified_ad.description.truncate(250)
      @classified_ad_path = "#{root_url}annonce/#{@conversation.classified_ad.id}"
      @user_name = user.display_name
      email_to = get_email_to user.account.account_emails.first.email
      mail(to: email_to, subject: "Une de vos offres a été rejetée sur Idipops.com")
    end
  end

  def accepted_conversation_email conversation_id, user_id, reason
    user = User.find(user_id)
    if user.email_notifications
      @conversation = Conversation.find(conversation_id)
      @accept_reason = convert_linebreaks reason
      @content = convert_linebreaks @conversation.classified_ad.description.truncate(250)
      @classified_ad_path = "#{root_url}annonce/#{@conversation.classified_ad.id}"
      @user_name = user.display_name
      email_to = get_email_to user.account.account_emails.first.email
      mail(to: email_to, subject: "Une de vos offres a été acceptée sur Idipops.com")
    end
  end

  def referral_users_email user_id, emails, subject, message
    @user = User.find(user_id)
    @referral_accept_path = "#{root_url}invitations/accepte/#{@user.token}"
    @message = message
    mail(to: get_email_to(emails), subject: (subject || "Une de vos offres a été acceptée sur My Uneo.com"))
  end

  def processed_referral_email user_id, email, reward
    user = User.find(user_id)
    @email,@reward = email,reward
    if user.email_notifications
      @user_name = user.display_name
      email_to = get_email_to user.account.account_emails.first.email
      mail(to: email_to, subject: "Une de vos offres a été acceptée sur Idipops.com")
    end
  end

  private

  def get_email_to email
    unless Rails.env.production?
      email = "benjamin.durin@gmail.com"
    end
    email
  end
end