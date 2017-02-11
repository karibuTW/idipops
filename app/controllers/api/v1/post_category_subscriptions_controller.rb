class Api::V1::PostCategorySubscriptionsController < ApiController

  def create
    if signed_in?
      post_category = PostCategory.find(params[:category_id])
      if post_category.present?
        post_category_subscription = PostCategorySubscription.new( user: current_user, post_category: post_category)
        if post_category_subscription.save
          render json: post_category_subscription, status: :ok
        else
          render json: post_category_subscription.errors, status: :unprocessable_entity
        end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def destroy
    if signed_in?
      post_category_subscription = PostCategorySubscription.find(params[:id])
      if post_category_subscription.present?
        post_category_subscription.destroy
        render json: nil, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

	# def index
 #    if params.has_key?(:category_id)
 #      subscriptions = PostCategorySubscription.where(post_category_id: params[:category_id])
 #      render json: subscriptions, status: :ok, each_serializer: PostCategorySubscriptionSerializer
 #    elsif signed_in?
 #      gfdgf
 #    else
 #      render json: nil, status: :unauthorized
 #    end
 #  end

end