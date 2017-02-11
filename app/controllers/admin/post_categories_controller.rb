class Admin::PostCategoriesController < AdminController

  def index
    @post_categories = PostCategory.sort_by_ancestry(PostCategory.all)
  end

  def edit
    @post_category = PostCategory.find_by(id: params[:id])
  end

  def update
    @post_category = PostCategory.find_by(id: params[:id])
    if @post_category.update_attributes(post_categories_params)
      flash[:notice] = "Catégorie #{@post_category.name} modifiée"
      redirect_to admin_post_categories_path
    else
      flash[:alert] = "La modification de la catégorie a échoué"
      render :edit
    end
  end

  def new
    @post_category = PostCategory.new
    @post_category.active = true
  end

  def create
    @post_category = PostCategory.new(post_categories_params)
    if @post_category.save
      flash[:notice] = "Catégorie #{@post_category.name} ajoutée"
      redirect_to admin_post_categories_path
    else
      flash[:alert] = "L'ajout de la catégorie a échoué"
      render :new
    end
  end

  private

  def post_categories_params
    params.require(:post_category).permit(:name, :active, :parent_id, profession_ids: [])
  end

end