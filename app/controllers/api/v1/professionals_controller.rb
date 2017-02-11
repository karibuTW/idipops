class Api::V1::ProfessionalsController < ApiController

	def index
		if params.has_key?(:lat) && params.has_key?(:lng)
			lat_lng = Geokit::LatLng.new(params[:lat], params[:lng])
			unsorted_professionals = Hash.new { |hash, key| hash[key] = [] }
			professionnals_array = Array.new()
	  	professionnals = Array.new()
			sorting = params[:sort] || 'distance'
			selected_pros = User.pro.active.includes([:addresses, {addresses: :opening_hours}])
			if params.has_key?(:rating) && params[:rating].present?
				selected_pros = selected_pros.where('rating >= ?', params[:rating])
			end
			if params.has_key?(:tags) && params[:tags].present?
				selected_pros = selected_pros.tagged_with(params[:tags], any: true)
			end
			if params.has_key?(:cname)
				selected_pros = selected_pros.where(company_name: params[:cname])
			end
			if params.has_key?(:profession_ids)
				selected_pros = selected_pros.with_activity(params[:profession_ids])
			end
			if sorting == 'distance'
				selected_pros.find_each do |pro|
					distance = get_shortest_distance_from_pro(pro, lat_lng)
					if distance >= 0
						professionnals_array << [distance, pro]
					end
				end
				professionnals_array.each { |x,y| unsorted_professionals[x] << y }
		  	unsorted_professionals.sort_by{ |k,v| k}.to_h.map do |key,value|
		  		professionnals.concat value
		  	end
			else
				selected_pros.order(rating: :desc).each do |pro|
					distance = get_shortest_distance_from_pro(pro, lat_lng)
					if distance > 0
						professionnals << pro
					end
				end
			end
			sponsored_ids = ProfileSponsoring.where(display_location: "sponsored_profile").where('remaining_impressions > 0').pluck(:user_id)
			sponsored_professionals = Array.new()
			if sponsored_ids.count > 0
				max = 3
				professionnals.each_with_index do |pro, index|
					if sponsored_ids.include?(pro.id)
						sponsored_professionals << pro
						selected_profile = ProfileSponsoring.where(display_location: "sponsored_profile", user: pro).first
						if selected_profile.present?
							selected_profile.remaining_impressions = selected_profile.remaining_impressions - 1
							selected_profile.save
						end
						max = max - 1
					end
					break unless max > 0
				end
				professionnals = professionnals - sponsored_professionals
				# professionnals = sponsored_professionals + professionnals
			end
			 #render json: professionnals, status: :ok
			render json: { sponsored: ActiveModel::ArraySerializer.new(sponsored_professionals, each_serializer: UserSerializer, scope: view_context) , regular: ActiveModel::ArraySerializer.new(professionnals, each_serializer: UserSerializer, scope: view_context) }, status: :ok
		elsif params.has_key?(:search)
			search = params[:search].gsub(/[!%&",.():;?]/,'')
			if params[:with_quotation] == "1"
				professionnals = User.pro.active.where(quotation: true)
				if params.has_key?(:qrt_id) && params[:qrt_id].present?
					professions_with_template = Profession.where(quotation_request_template_id: params[:qrt_id])
					professionnals = professionnals.where(primary_activity: professions_with_template)
				end
			else
				professionnals = User.pro.active
			end
			professionnals = professionnals.where("company_name LIKE ?", "%#{search}%").order(company_name: :asc)

			render json: professionnals, status: :ok, each_serializer: SearchProSerializer
		else
			render json: nil, status: :unprocessable_entity
		end
  end

  def show
  	pro = User.find_by(pretty_name: params[:id]) || User.find_by(id:params[:id])
    if pro.present? && pro.is_pro?
    	if params.has_key?(:latitude) && params.has_key?(:longitude) && current_user != pro
    		ProfileView.create(user: pro, latitude: params[:latitude], longitude: params[:longitude])
    	end
      render json: pro
    else    
      render json: nil, status: :not_found
		end
  end

  private

  def is_in_distance (pro, lat_lng)
  	inside = false
  	pro.addresses.each do |address|
  		if lat_lng.distance_to(Geokit::LatLng.new(address.latitude, address.longitude), {units: :kms}) <= address.action_range
  			inside = true
  			break
  		end
  	end
  	return inside
  end

  def is_in_bounds (pro, bounds)
  	inside = false
  	pro.addresses.each do |address|
  		if bounds.contains?(Geokit::LatLng.new(address.latitude, address.longitude))
  			inside = true
  			break
  		end
  	end
  	return inside
  end

end