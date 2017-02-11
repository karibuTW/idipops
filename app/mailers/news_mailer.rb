class NewsMailer < ApplicationMailer

	def new_password_email user_id, password
		@password = password
		@user_to = User.find(user_id)
		@root_url = root_url
    if @user_to.email_notifications
    	@post_post_path = "#{root_url}poster-post"
      email_to = @user_to.account.account_emails.first.email
      mail(to: email_to, subject: "Nouveau mot de passe pour Idipops")
    end
	end

end