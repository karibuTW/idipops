class Api::V1::UsersFavoriteDealsController < ApiController

	def index
    if signed_in?
    	render json: current_user.favorite_deals, status: :ok, each_serializer: DealSerializer
    else
    	render json: nil, status: :unauthorized
    end
  end

  def create
    if signed_in?
    	if params.has_key?(:id) && params[:id].present?
    		deal = Deal.find(params[:id])
    		if deal.present?
          if !current_user.favorite_deals.include?(deal)
      			current_user.favorite_deals << deal
          end
    			render json: current_user.users_favorite_deals.where(deal_id: deal.id).first.deal, status: :ok
    		else
    			render json: nil, status: :not_found
    		end
    	else
    		render json: nil, status: :unprocessable_entity
    	end
    else
      render json: nil, status: :unauthorized
    end
  end

  def destroy
  	if signed_in?
    	if params.has_key?(:id) && params[:id].present?
    		favorite_to_remove = UsersFavoriteDeal.find(params[:id])
    		if favorite_to_remove.present?
    			favorite_to_remove.destroy
    			render json: nil, status: :ok
    		else
    			render json: nil, status: :not_found
    		end
    	else
    		render json: nil, status: :unprocessable_entity
    	end
    else
      render json: nil, status: :unauthorized
    end
  end

end