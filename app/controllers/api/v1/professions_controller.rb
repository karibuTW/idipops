class Api::V1::ProfessionsController < ApiController

	def index
    professions = Array.new()
    Profession.active.roots.order(name: :asc).find_each do |pro|
    	if pro.has_children?
    		professions << pro
    	end
    end
    render json: professions, status: :ok, each_serializer: ProfessionSerializer
  end

  def show
  	profession = Profession.find(params[:id])
  	if profession.present?
  		render json: profession, status: :ok
  	else
  		render json: nil, status: :not_found
  	end
  end

end