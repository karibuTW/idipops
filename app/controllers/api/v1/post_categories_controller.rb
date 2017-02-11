class Api::V1::PostCategoriesController < ApiController

	def index
    categories = Array.new()
    PostCategory.active.roots.order(name: :asc).find_each do |cat|
    	if cat.has_children?
    		categories << cat
    	end
    end
    render json: categories, status: :ok, each_serializer: PostCategorySerializer
  end

  def show
  	category = PostCategory.find(params[:id])
  	if category.present?
  		render json: category, status: :ok
  	else
  		render json: nil, status: :not_found
  	end
  end

end