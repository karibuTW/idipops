class Api::V1::SessionsController < ApiController

  skip_before_action :verify_authenticity_token

  def create
    account_email = AccountEmail.find_by(email: create_params[:email])
    if account_email.present?
      account = account_email.account
      user = account.users.first unless !account.present?
      if user && user.active? && account.authenticate(create_params[:password])
        sign_out
        session[:current_account_id] = account.id
        user.log_signin
        render json: nil, status: :no_content
      else
        render json: nil, status: :unauthorized # user not found
      end
    else
      render json: nil, status: :not_found
    end
  end

  def destroy
    old_session_user_id = session[:current_account_id]
    sign_out
    render json: nil, status: 200
  end

  private

  def create_params
    params.permit(:email, :password)
  end

end