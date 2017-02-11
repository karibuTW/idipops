class Api::V1::QuotationRequestTemplatesController < ApiController

  def show
    if signed_in?
      qrt = QuotationRequestTemplate.find(params[:id])
      if qrt.present?
      	render json: qrt, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end
  
end