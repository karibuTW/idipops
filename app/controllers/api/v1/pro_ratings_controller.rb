class Api::V1::ProRatingsController < ApiController

	def create
    if signed_in?
      professional = User.find(params[:pro_id])
      if professional.present? && params[:rating] > 0 && params[:rating] < 6
        pro_rating = ProRating.where(professional: professional, user: current_user).first_or_initialize
        if pro_rating.update_attributes(rating: params[:rating])
          count = ProRating.where(professional: professional).count
          if count > 0
            sum = ProRating.where(professional: professional).sum(:rating)
            new_rating = (sum / count).round
            professional.rating = new_rating
            professional.save
          else
            new_rating = 0
          end
          render json: new_rating, status: :created
        else
          render json: pro_rating.errors, status: :unprocessable_entity
        end
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end