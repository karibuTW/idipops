class Admin::PriceForCategoriesController < AdminController

  # def index
  #   @pricings = Pricing.order(start_date: :desc)
  # end

  def edit
    @available_categories_for_pricing = available_categories_for_pricing Pricing.find(params[:pricing_id])
    @price_for_category = PriceForCategory.find(params[:id])
  end

  def update
    @price_for_category = PriceForCategory.find(params[:id])
    if @price_for_category.update_attributes(pricing_params)
      flash[:notice] = "Prix modifié pour #{@price_for_category.pricing.target}"
      redirect_to admin_pricings_path
    else
      flash[:alert] = "La modification du prix a échoué"
      render :edit
    end
  end

  def new
    @available_categories_for_pricing = available_categories_for_pricing Pricing.find(params[:pricing_id])
    @price_for_category = PriceForCategory.new({ pricing_id: params[:pricing_id] })
  end

  def create
    @price_for_category = PriceForCategory.new(pricing_params)
    if @price_for_category.update_attributes(pricing_params)
      flash[:notice] = "Prix ajouté pour #{@price_for_category.pricing.target}"
      redirect_to admin_pricings_path
    else
      flash[:alert] = "L'ajout du prix a échoué"
      render :new
    end
  end

  private

  def available_categories_for_pricing pricing
    used_pricing_category_ids = pricing.pricing_categories.pluck(:id)
    PricingCategory.where.not(id: used_pricing_category_ids)
  end

  def pricing_params
    params.require(:price_for_category).permit(:credit_amount, :amount_cents, :pricing_category_id, :pricing_id)
  end

end