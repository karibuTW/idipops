class Api::V1::PostCommentsController < ApiController

  def index
    if params.has_key?(:id) && params[:id].present?
      post = Post.find_by(slug: params[:id]) || Post.find(params[:id])
      if post.present?
        comments = PostComment.where(post: post).order(updated_at: :desc)
        render json: comments, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unprocessable_entity
    end
  end

	def create
    if signed_in?
      post = Post.find_by(slug: params[:post_id]) || Post.find(params[:post_id])
      if post.present? && params.has_key?(:content) && params[:content].present?
        post_comment = PostComment.new(post: post, user: current_user)
        if post_comment.update_attributes(content: params[:content])
          params[:content].scan(/@\b[a-zA-Z0-9\u00C0-\u017F\-]+/) do |mention|
            mention.delete!("@")
            user_mentioned = User.find_by_pretty_name(mention)
            if user_mentioned.present?
              begin
                post_user_mention = PostCommentUserMention.create(user: user_mentioned, post_comment: post_comment)
                post_comment.post_user_mentions << post_user_mention
              rescue
                #Already exist
              end
            end
          end
          post_comment.send_notifications
          render json: nil, status: :created
        else
          render json: post_comment.errors, status: :unprocessable_entity
        end
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end