class Api::V1::ProReviewsController < ApiController

  def index
    if params.has_key?(:id) && params[:id].present?
      professional = User.find(params[:id])
      if professional.present?
        reviews = ProReview.where(professional: professional).order(updated_at: :desc)
        render json: reviews, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unprocessable_entity
    end
  end

	def create
    if signed_in?
      professional = User.find(params[:pro_id])
      if professional.present? && params.has_key?(:content) && params[:content].present?
        pro_review = ProReview.where(professional: professional, user: current_user).first_or_initialize
        if pro_review.update_attributes(content: params[:content])
          render json: nil, status: :created
        else
          render json: pro_review.errors, status: :unprocessable_entity
        end
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end