class Api::V1::UsersFavoritePostsController < ApiController

	def index
    if signed_in?
    	render json: current_user.favorite_posts, status: :ok, each_serializer: UsersFavoritePostSerializer
    else
    	render json: nil, status: :unauthorized
    end
  end

  def create
    if signed_in?
    	if params.has_key?(:id) && params[:id].present?
    		post = Post.find(params[:id])
    		if post.present?
          if !current_user.favorite_posts.include?(post)
      			current_user.favorite_posts << post
          end
    			render json: current_user.users_favorite_posts.where(post_id: post.id).first.post, status: :ok
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
    		favorite_to_remove = UsersFavoritePost.find(params[:id])
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