class Admin::ReviewsController < AdminController
	def index
		@reviews = ProReview.includes(:user,:professional).order(created_at: :desc)
	end

	def show
		@review = ProReview.includes(:user,:professional).find(params[:id])
	end

  def destroy
    @review = ProReview.find(params[:id])
    @review.destroy
    flash[:notice] = "Pro review #{params[:id]} supprimé"
    redirect_to admin_reviews_path
  end
end