class Admin::PricingsController < AdminController

  def index
    @pricings = Pricing.order(start_date: :desc)
  end

  def edit
    @pricing = Pricing.find(params[:id])
  end

  def update
    @pricing = Pricing.find(params[:id])
    if @pricing.update_attributes(pricing_params)
      flash[:notice] = "Prix pour #{@pricing.target} modifié"
      redirect_to admin_pricings_path
    else
      flash[:alert] = "La modification du prix a échoué"
      render :edit
    end
  end

  def new
    @pricing = Pricing.new
  end

  def create
    @pricing = Pricing.new(pricing_params)
    if @pricing.save
      flash[:notice] = "Prix ajouté pour #{@pricing.target}"
      redirect_to admin_pricings_path
    else
      flash[:alert] = "L'ajout du prix a échoué"
      render :new
    end
  end

  private

  def pricing_params
    params.require(:pricing).permit(:target, :start_date)
  end

end