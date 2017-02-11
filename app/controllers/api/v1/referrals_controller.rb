class Api::V1::ReferralsController < ApiController

	def create
    if signed_in?
      if current_user.create_and_send_referral_emails(referral_params[:emails],referral_params[:subject],referral_params[:message])
        referrals = current_user.referrals.includes(:customer)
        render json: referrals, status: :ok, each_serializer: ReferralSerializer
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def list
    if signed_in?
      referrals = current_user.referrals.includes(:customer)
      # template = EmailTemplate.find_by(name: "referral_template")
      pricing = Pricing.active('bonus_referral')
      price_for_category = pricing.price_for_categories.last
      reward = price_for_category.present? ? price_for_category.credit_amount : 0
      # message = template.body
      render json: {referrals: ActiveModel::ArraySerializer.new(referrals, each_serializer: ReferralSerializer, scope: view_context), reward: reward.to_s, total_referral_rewards: current_user.total_referral_rewards}, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  private

  def referral_params
    params.permit(:subject, :message, emails: [])
  end

end