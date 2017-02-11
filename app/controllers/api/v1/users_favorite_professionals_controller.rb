class Api::V1::UsersFavoriteProfessionalsController < ApiController

	def index
    if signed_in?
    	render json: current_user.favorite_professionals, status: :ok, each_serializer: UsersFavoriteProfessionalSerializer
    else
    	render json: nil, status: :unauthorized
    end
  end

  def create
    if signed_in? && !current_user.is_pro?
    	if params.has_key?(:id) && params[:id].present?
    		professional = User.find(params[:id])
    		if professional.present?
          if !current_user.favorite_professionals.include?(professional)
      			current_user.favorite_professionals << professional
          end
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

  def destroy
  	if signed_in? && !current_user.is_pro?
    	if params.has_key?(:id) && params[:id].present?
    		favorite_to_remove = UsersFavoriteProfessional.where(professional_id: params[:id], user_id: current_user.id).first
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