class Api::V1::PricingsController < ApiController
	def index
		if signed_in?
      if params.has_key?(:deals)
        pricings = Pricing.where("target LIKE 'deal_%'").select { |pricing| pricing.active? }
      elsif params.has_key?(:fleches)
        pricings = Pricing.where("target IN ('forfait_1', 'forfait_2', 'forfait_3', 'forfait_4', 'change_rate')").select { |pricing| pricing.active? }
      elsif params.has_key?(:profile)
        pricings = Pricing.where("target IN ('sponsored_profile', 'sponsored_map_profile')").select { |pricing| pricing.active? }
      elsif params.has_key?(:posts)
        pricings = Pricing.where("target IN ('sponsored_post')").select { |pricing| pricing.active? }
      else
        pricings = Pricing.select { |pricing| pricing.active? }
      end
      render json: pricings, status: :ok
		else
			render json: nil, status: :unauthorized
		end
	end

  def show
    if signed_in?
      pricing = Pricing.active(params[:id])
      if pricing.present?
        render json: pricing, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end