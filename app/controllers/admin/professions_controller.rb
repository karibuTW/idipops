class Admin::ProfessionsController < AdminController

  def index
    @professions = Profession.sort_by_ancestry(Profession.all)
  end

  def edit
    @profession = Profession.find_by(id: params[:id])
  end

  def update
    @profession = Profession.find_by(id: params[:id])
    if @profession.update_attributes(profession_params)
      flash[:notice] = "Profession #{@profession.name} modifiée"
      redirect_to admin_professions_path
    else
      flash[:alert] = "La modification de la profession a échoué"
      render :edit
    end
  end

  def new
    @profession = Profession.new
    @profession.active = true
  end

  def create
    @profession = Profession.new(profession_params)
    if @profession.save
      flash[:notice] = "Profession #{@profession.name} ajoutée"
      redirect_to admin_professions_path
    else
      flash[:alert] = "L'ajout de la profession a échoué"
      render :new
    end
  end

  private

  def profession_params
    params.require(:profession).permit(:name, :active, :description, :parent_id, :image, :quotation_request_template_id, :pricing_category_id)
  end

end