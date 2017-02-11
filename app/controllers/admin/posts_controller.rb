class Admin::PostsController < AdminController
	def index
		@posts = Post.order(created_at: :desc).paginate(page: params[:page], per_page: 50)
	end

	def show
		@post = Post.find(params[:id])
	end

	def update
    post = Post.find(params[:id])
    if post.present?
      if params[:workflow_event] == "accept"
        post.accept!
      elsif params[:workflow_event] == "reject"
        post.reject!(params[:post][:reject_reason])
      end
      flash[:notice] = "Le post #{post.id} a maintenant le statut : #{post.current_state}"
    else
      flash[:alert] = "Post introuvable!"
    end
    redirect_to admin_post_path(post)
  end

end