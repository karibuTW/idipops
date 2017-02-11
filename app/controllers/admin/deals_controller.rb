class Admin::DealsController < AdminController
	def index
		@deals = Deal.order(created_at: :desc)
	end

	def show
		@deal = Deal.find(params[:id])
	end

  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy
    flash[:notice] = "Bon plan #{@deal.id} supprimé"
    redirect_to admin_deals_path
  end

end