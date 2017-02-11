class UserMailer < ApplicationMailer
  # default from: "from@example.com"

  def new_password_request_email user_to_id, password
    @user_to = User.find(user_to_id)
    @password = password
    @connexion_path = "#{root_url}connexion"
    @profile_path = "#{root_url}u/modifier"
    email_to = @user_to.account.account_emails.first.email
    mail(to: email_to, subject: "Réinitialisation du mot de passe sur Idipops")
  end

end