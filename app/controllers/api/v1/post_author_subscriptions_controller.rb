class Api::V1::PostAuthorSubscriptionsController < ApiController

  def create
    if signed_in?
      author = User.find_by(pretty_name: params[:author_pretty_name])
      if author.present?
        post_author_subscription = PostAuthorSubscription.new( user: current_user, author: author)
        if post_author_subscription.save
          render json: post_author_subscription, status: :ok
        else
          render json: post_author_subscription.errors, status: :unprocessable_entity
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
      post_author_subscription = PostAuthorSubscription.find(params[:id])
      if post_author_subscription.present?
        post_author_subscription.destroy
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