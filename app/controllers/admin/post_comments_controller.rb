class Admin::PostCommentsController < AdminController
	def index
		@post_comments = PostComment.all.order(created_at: :desc)
	end

	def show
		@post_comment = PostComment.find(params[:id])
	end

  def destroy
    @comment = PostComment.find(params[:id])
    @comment.destroy
    flash[:notice] = "Commentaire #{params[:id]} supprimé"
    redirect_to admin_post_comments_path
  end
end