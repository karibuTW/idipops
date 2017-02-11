class Api::V1::ProfileSponsoringsController < ApiController
	def create
		if signed_in? && current_user.is_pro?
			pricing = Pricing.active(params[:target])
			if pricing.present? && pricing.active?
        price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
        if price_for_category.present?
          price = price_for_category.credit_amount
          if price > current_user.balance
						render json: nil, status: :payment_required
					else
						transaction = CreditTransaction.create(user: current_user, credit_amount: -price, description: price_for_category.pricing.target)
						transaction.accept!
						profile_sponsoring = ProfileSponsoring.where(user: current_user, display_location: price_for_category.pricing.target).first
						if profile_sponsoring.present?
							profile_sponsoring.update_attributes(initial_impressions: profile_sponsoring.initial_impressions + 1000, remaining_impressions: profile_sponsoring.remaining_impressions + 1000)
							profile_sponsoring.reload
						else
							profile_sponsoring = ProfileSponsoring.create(user: current_user, credit_transaction: transaction, display_location: price_for_category.pricing.target, initial_impressions: 1000, remaining_impressions: 1000)
						end
						render json: profile_sponsoring, status: :created
					end
				else
					render json: nil, status: :unprocessable_entity
				end
			else
				render json: nil, status: :unprocessable_entity
			end
		else
      render json: nil, status: :unauthorized
		end
	end

	def index
		if params.has_key?(:ids)
			profiles = ProfileSponsoring.where(user_id: params[:ids], display_location: "sponsored_map_profile").where('remaining_impressions > 0').limit(6)
			profile_ids = profiles.pluck(:user_id)
			profiles.each do |profile|
				if !session["pmp#{profile.id}"].present?
		  		session["pmp#{profile.id}"] = 1
		  		profile.remaining_impressions = profile.remaining_impressions - 1
		  		profile.save
		  	end
			end
			render json: profile_ids, status: :ok
		# elsif params.has_key?(:lat) && params.has_key?(:lng)
		# 	lat_lng = Geokit::LatLng.new(params[:lat], params[:lng])
		# 	unsorted_professionals = Hash.new { |hash, key| hash[key] = [] }
		# 	professionnals_array = Array.new()
	 #  	professionnals = Array.new()
		# 	profiles = ProfileSponsoring.where(display_location: "sponsored_profile").where('remaining_impressions > 0')
		# 	all_candidates = User.pro.active.where(id: profiles.pluck(:user_id))
		# 	max = 3
		# 	if all_candidates.count > max
		# 		if params.has_key?(:tags) && params[:tags].present?
		#   		tagged_pros = all_candidates.tagged_with(params[:tags])
		# 	  else
		# 	  	tagged_pros = all_candidates
		# 	  end
		# 	  if tagged_pros.count > max
		# 	  	if params.has_key?(:pids) && params[:pids].present?
		# 		  	pros_with_activity = tagged_pros.with_activity(params[:pids])
		# 		  else
		# 		  	pros_with_activity = tagged_pros
		# 		  end
		# 		  if pros_with_activity.count > max
		# 		  	if params.has_key?(:cnames) && params[:cnames].present?
		# 			  	users_with_tag = User.tagged_with(params[:cnames]).pluck(:id)
		# 			  	users_with_name = User.where(company_name: params[:cnames]).pluck(:id)
		# 			  	sponsored_pros = pros_with_activity.where(id: (users_with_name + users_with_tag).uniq!)
		# 			  else
		# 			  	sponsored_pros = pros_with_activity
		# 			  end
		# 			else
		# 				sponsored_pros = pros_with_activity
		# 		  end
		# 		else
		# 			sponsored_pros = tagged_pros
		# 	  end
		# 	else
		# 		sponsored_pros = all_candidates
		# 	end
		# 	sponsored_pros.find_each do |pro|
		# 		distance = get_shortest_distance_from_pro(pro, lat_lng)
		# 		if distance >= 0
		# 			professionnals_array << [distance, pro]
		# 		end
		# 	end
		# 	professionnals_array.each { |x,y| unsorted_professionals[x] << y }
	 #  	unsorted_professionals.sort_by{ |k,v| k}.to_h.map do |key,value|
	 #  		professionnals.concat value
	 #  	end
		# 	render json: professionnals[0..max-1].map(&:id), status: :ok
		else
			render json: nil, status: :unprocessable_entity
		end
	end

end