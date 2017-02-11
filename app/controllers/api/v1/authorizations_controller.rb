class Api::V1::AuthorizationsController < ApiController
	def create
    if signed_in? && current_user.is_pro?
      pricing = Pricing.active(params[:target])
      if pricing.present? && pricing.active?
        price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
        if price_for_category.present?
          price = price_for_category.credit_amount
          if current_user.balance < price
            render json: nil, status: :payment_required
          else
            if params[:target] == 'classified_ad_unlock'
              classified_ad = ClassifiedAd.find(params[:ad_id])
              if classified_ad.present?
                transaction = CreditTransaction.create(user: current_user, credit_amount: -price, description: "classified_ad_unlock")
                transaction.accept!
                authorization = Authorization.create(credit_transaction: transaction, classified_ad: classified_ad)
                render json: authorization, status: :created
              else
                render json: nil, status: :not_found
              end
            else
              render json: nil, status: :unprocessable_entity
            end
          end
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