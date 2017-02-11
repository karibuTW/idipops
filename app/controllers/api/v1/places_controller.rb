class Api::V1::PlacesController < ApiController

	def index
		places = Place.fr
		if params.has_key?(:name_starts_with)
      places = places.name_starts_with(params[:name_starts_with]).order(place_name: :asc)
		elsif params.has_key?(:code_starts_with)
      places = places.code_starts_with(params[:code_starts_with]).order(postal_code: :asc)
    elsif params.has_key?(:starts_with)
      places = places.starts_with(params[:starts_with]).order(place_name: :asc)
	  end
    render json: places, status: :ok, each_serializer: PlaceSerializer
  end

  def departements
  	places = Place.fr.group(:admin_code2)
		if params.has_key?(:departement_starts_with)
      places = places.departement_starts_with(params[:departement_starts_with])
		elsif params.has_key?(:code_starts_with)
      places = places.code_starts_with(params[:code_starts_with])
    elsif params.has_key?(:departement_code_starts_with)
      places = places.departement_code_starts_with(params[:departement_code_starts_with])
	  end
    render json: places, status: :ok, each_serializer: DepartementSerializer
  end

  def show
    place = Place.find(params[:id])
    if place.present?
      render json: place, status: :ok
    else
      render json: nil, status: :not_found
    end
  end

end