class Api::V1::UsersFavoritePostCommentsController < ApiController

  def create
    if signed_in?
    	if params.has_key?(:id) && params[:id].present?
    		post_comment = PostComment.find(params[:id])
    		if post_comment.present?
          if !current_user.favorite_post_comments.include?(post_comment)
      			current_user.favorite_post_comments << post_comment
          end
    			render json: post_comment, status: :ok
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
    		favorite_to_remove = UsersFavoritePostComment.find(params[:id])
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