class Api::V1::DealsController < ApiController
	def create
		if signed_in? && current_user.is_pro?
			if params[:address_ids].present?
				@pricings_needed = Array.new()
				@total_amount = 0
				set_needed_pricings params[:address_ids]
				if @total_amount > current_user.balance
					render json: nil, status: :payment_required
				else
					deal = Deal.create(user: current_user)
					if deal.present?
						if params.has_key?(:featured_image) && params[:featured_image].present?
							params[:featured_image] = Base64.decode64(params[:featured_image][params[:featured_image].index(',') .. -1])
						end
						if params.has_key?(:list_image) && params[:list_image].present?
							params[:list_image] = Base64.decode64(params[:list_image][params[:list_image].index(',') .. -1])
						end
						if deal.update_attributes(deal_params)
							@pricings_needed.each do |price_for_category|
								transaction = CreditTransaction.create(user: current_user, credit_amount: -price_for_category.credit_amount, description: price_for_category.pricing.target)
								transaction.accept!
								deal_promotion = DealPromotion.create(deal: deal, credit_transactions: [transaction], display_location: price_for_category.pricing.target, tag_list: params[:tag_list], initial_impressions: 1000, remaining_impressions: 1000)
							end
							if @price_for_additional_addresses.present?
								transaction = CreditTransaction.create(user: current_user, credit_amount: -@price_for_additional_addresses, description: "deal_more_addresses")
								transaction.accept!
							end
							render json: deal, status: :created
						else
							render json: deal.errors, status: :unprocessable_entity
						end
					else
						render json: deal.errors, status: :unprocessable_entity
					end
				end
			else
				render json: nil, status: :bad_request
			end
    else
      render json: nil, status: :unauthorized
    end
	end

	def destroy
    deal = Deal.find(params[:id])
    if deal.destroy
    	render json: nil, status: :ok
    else
    	render json: deal.errors, status: :unprocessable_entity
    end
  end

	def update
		if signed_in?
			@pricings_needed = Array.new()
			@total_amount = 0
			deal = Deal.find(params[:id])
			if deal.present?
				set_needed_pricings deal.addresses.pluck(:id)
				if @total_amount > current_user.balance
					render json: nil, status: :payment_required
				else
					if params.has_key?(:featured_image) && params[:featured_image].present?
						params[:featured_image] = Base64.decode64(params[:featured_image][params[:featured_image].index(',') .. -1])
					end
					if params.has_key?(:list_image) && params[:list_image].present?
						params[:list_image] = Base64.decode64(params[:list_image][params[:list_image].index(',') .. -1])
					end
		      if deal.update_attributes(deal_params)
		      	@pricings_needed.each do |price_for_category|
							transaction = CreditTransaction.create(user: current_user, credit_amount: -price_for_category.credit_amount, description: price_for_category.pricing.target)
							transaction.accept!
							deal_promotion = DealPromotion.where(deal: deal, display_location: price_for_category.pricing.target).first
							if deal_promotion.present?
								deal_promotion.credit_transactions << transaction
								deal_promotion.update_attributes(initial_impressions: deal_promotion.initial_impressions + 1000, remaining_impressions: deal_promotion.remaining_impressions + 1000)
							else
								deal_promotion = DealPromotion.create(deal: deal, credit_transactions: [transaction], display_location: price_for_category.pricing.target, tag_list: params[:tag_list], initial_impressions: 1000, remaining_impressions: 1000)
							end
						end
						DealPromotion.where(deal: deal).each do |deal_promotion|
							deal_promotion.tag_list = params[:tag_list]
							deal_promotion.save
						end
		      	render json: deal, status: :ok
		      else
		      	render json: deal.errors, status: :unprocessable_entity
		      end
		    end
	    else
	    	render json: nil, status: :not_found
	    end
    else
      render json: nil, status: :unauthorized
    end
	end

	def index
		if params.has_key?(:mine)
			if signed_in? && current_user.is_pro?
				deals = Deal.all.where(user: current_user)
			else
	      render json: nil, status: :unauthorized
	      return
	    end
	  elsif params.has_key?(:prom_type)
	  	max = params[:limit].to_i || 5
	  	lat_lng = Geokit::LatLng.new(params[:lat], params[:lng])
	  	
	  	if params[:prom_type] == 'homepage'
		  	all_deals = get_filtered_deals_by_session_views(Deal.active.joins(:deal_promotions).includes(:deal_promotions).where('deal_promotions.display_location = ? AND deal_promotions.remaining_impressions > 0', 'deal_homepage').order(created_at: :desc), max)
		  	if all_deals.count <= max
		  		deals = all_deals
		  	else
		  		deals = get_max_number_of_deals(all_deals, max, lat_lng)
		  	end
		  elsif params[:prom_type] == 'deals'
		  	all_deals = get_filtered_deals_by_session_views(Deal.active.joins(:deal_promotions).includes(:deal_promotions).where('deal_promotions.display_location = ? AND deal_promotions.remaining_impressions > 0', 'deal_deals').order(created_at: :desc), max)
		  	if all_deals.count <= max
		  		deals = all_deals
		  	else
			  	if params.has_key?(:tags) && params[:tags].present?
			  		tagged_promoted_deal_ids = DealPromotion.tagged_with(params[:tags]).map(&:deal_id)
				  	tagged_deals = all_deals.where(id: tagged_promoted_deal_ids)
				  else
				  	tagged_deals = all_deals
				  end
				  if params.has_key?(:pid) && params[:pid].present?
				  	users_with_activity = User.with_activity([params[:pid]])
				  	deals = tagged_deals.where(user: users_with_activity)
				  elsif params.has_key?(:uid) && params[:uid].present?
				  	deals = tagged_deals.where(user_id: params[:uid])
				  else
				  	deals = tagged_deals
				  end
				  if deals.count < max
				  	deals = tagged_deals
				  	if deals.count < max
				  		deals = all_deals
				  	end
				  end
				  if deals.count > max
				  	deals = get_max_number_of_deals(deals, max, lat_lng)
				  end
				end
		  elsif params[:prom_type] == 'similar'
		  	current_deal = Deal.find(params[:did])
		  	if current_deal.present?
			  	all_deals = Deal.active.order(created_at: :desc)
			  	if all_deals.count > max
			  		# if current_deal.deal_promotions.count > 0
			  		# 	tags = Array.new()
			  		# 	current_deal.deal_promotions.each do |promo|
			  		# 		tags.concat promo.tag_list
			  		# 	end
			  		# 	tags.uniq!
			  		# 	# tags = current_deal.deal_promotion.tag_list
					  # else
					  # 	tags = current_deal.user.tag_list
			  		# end
		  			# tagged_promoted_deal_ids = DealPromotion.tagged_with(tags).map(&:deal_id).uniq!
		  			activities = Array.new()
		  			activities << current_deal.user.primary_activity_id
		  			activities << current_deal.user.secondary_activity_id if current_deal.user.secondary_activity_id.present?
		  			activities << current_deal.user.tertiary_activity_id if current_deal.user.tertiary_activity_id.present?
		  			activities << current_deal.user.quaternary_activity_id if current_deal.user.quaternary_activity_id.present?
		  			user_with_activity_ids = User.with_activity(activities).pluck(:id)
				  	deals = all_deals.where('deals.id IN (?) OR deals.user_id in (?)', tagged_promoted_deal_ids, user_with_activity_ids)
				  	if deals.count < max
				  		deals = all_deals
				  	end
				  	if deals.count > max
					  	deals = get_max_number_of_deals(deals, max, lat_lng)
					  end
				  else
				  	deals = all_deals
				  end
		  	else
		  		render json: nil, status: :not_found
		  		return
		  	end
		  elsif params[:prom_type] == 'map'
		  	all_deals = get_filtered_deals_by_session_views(Deal.active.joins(:deal_promotions).where('deal_promotions.display_location = ? AND deal_promotions.remaining_impressions > 0', 'deal_map').order(created_at: :desc), max)
		  	if all_deals.count <= max
		  		deals = all_deals
		  	else
			  	if params.has_key?(:tags) && params[:tags].present?
			  		tagged_promoted_deal_ids = DealPromotion.tagged_with(params[:tags]).map(&:deal_id)
				  	tagged_deals = all_deals.where(id: tagged_promoted_deal_ids)
				  else
				  	tagged_deals = all_deals
				  end
				  if tagged_deals.count > max
					  if params.has_key?(:pids) && params[:pids].present?
					  	users_with_activity = User.with_activity(params[:pids])
					  	p_deals = tagged_deals.where(user: users_with_activity).includes(:deal_promotions)
					  else
					  	p_deals = tagged_deals
					  end
					  if p_deals.count > max
						  if params.has_key?(:cnames) && params[:cnames].present?
						  	users_with_tag = User.tagged_with(params[:cnames]).pluck(:id)
						  	users_with_name = User.where(company_name: params[:cnames]).pluck(:id)
						  	deals = p_deals.where(user_id: (users_with_name + users_with_tag).uniq!).includes(:deal_promotions)
						  else
						  	deals = p_deals
						  end
						else
							deals = p_deals
						end
					else
						deals = tagged_deals
					end
					if deals.count > max
				  	deals = get_max_number_of_deals(deals, max, lat_lng)
				  end
				end
		  end
	  	
	  	if params[:prom_type] != 'similar'
	  		promotion_name = "deal_#{params[:prom_type]}"
	  		deal_promotions = DealPromotion.includes(:deal).where(deal: deals, display_location: promotion_name).where('remaining_impressions > 0')
	  		deal_promotions.find_each do |deal_promotion|
	  			deal_id = deal_promotion.deal.id
	  			if session["dp#{deal_id}"].present?
			  		session["dp#{deal_id}"] = session["dp#{deal_id}"] + 1
			  	else
			  		session["dp#{deal_id}"] = 1
			  	end
			  	deal_promotion.remaining_impressions = deal_promotion.remaining_impressions - 1
			  	deal_promotion.save
			  end
		  	# deals.find_each do |deal|
		  	# 	if session["dp#{deal.id}"].present?
			  # 		session["dp#{deal.id}"] = session["dp#{deal.id}"] + 1
			  # 	else
			  # 		session["dp#{deal.id}"] = 1
			  # 	end
			  # 	deal_promotion = deal.deal_promotions.where(display_location: promotion_name).where('remaining_impressions > 0').first
			  # 	if deal_promotion.present?
			  # 		deal_promotion.remaining_impressions = deal_promotion.remaining_impressions - 1
			  # 		deal_promotion.save
			  # 	end
		  	# end
		  end
	  elsif params.has_key?(:user_id)
	  	target_user = User.find_by(id: params[:user_id]) || User.find_by(pretty_name: params[:user_id])
	  	if target_user.present?
		  	deals = Deal.active.where(user_id: target_user.id).limit(params[:limit] || 2)
		  else
		  	deals = []
		  end
	  elsif params.has_key?(:lat) && params.has_key?(:lng)
	  	lat_lng = Geokit::LatLng.new(params[:lat], params[:lng])
	  	# deals_array = Array.new()
	  	active_deals = Deal.active
	  	if params.has_key?(:tags) && params[:tags].present?
	  		tagged_users = User.tagged_with(params[:tags])
		  	active_deals = Deal.active.where(user: tagged_users)
		  end
		  if params.has_key?(:pid) && params[:pid].present?
		  	users_with_activity = User.with_activity(params[:pid])
		  	active_deals = active_deals.where(user: users_with_activity)
		  elsif params.has_key?(:uid) && params[:uid].present?
		  	active_deals = active_deals.where(user_id: params[:uid])
		  end
		  unsorted_deals = Hash.new { |hash, key| hash[key] = [] }
		  deals_array = get_deals_within_distance(active_deals, lat_lng)
	  	deals_array[:within].each { |x,y| unsorted_deals[x] << y }
	  	deals = Array.new()
	  	unsorted_deals.sort.map do |key,value|
	  		deals.concat value
	  	end
	  else
	  	deals = Deal.active
		end
		render json: deals, status: :ok
	end

  def show
  	deal = Deal.find(params[:id])
  	if deal.present?
	  	render json: deal, status: :ok
	  else
      render json: nil, status: :not_found
    end
  end

	def deal_params
		params.permit(
      :tagline, 
      :description,
      :end_date,
      :start_date,
      :list_image,
      :featured_image,
      address_ids: []
    )
	end

	private

	def set_needed_pricings address_ids
		params[:promotions].each do |target, value|
			if value
				pricing = Pricing.active(target)
				if pricing.present? && pricing.active?
	        price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
	        if price_for_category.present?
	          @total_amount += price_for_category.credit_amount
						@pricings_needed << price_for_category
					else
						render json: nil, status: :unprocessable_entity
						return
					end
				else
					render json: nil, status: :unprocessable_entity
					return
				end
			end
		end
		if address_ids.present?
			addresses = Address.where(id: address_ids).includes(:opening_hours)
			num_of_addresses = addresses.count
			num_of_free_addresses = ENV['NUMBER_OF_FREE_ADDRESSES_FOR_DEALS'].to_i
			if num_of_addresses > num_of_free_addresses
				pricing = Pricing.active("deal_more_addresses")
				if pricing.present? && pricing.active?
					price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
	        if price_for_category.present?
	        	@price_for_additional_addresses = price_for_category.credit_amount * (num_of_addresses - num_of_free_addresses)
	        	@total_amount += @price_for_additional_addresses
	        end
				end
			end
		end
	end

	def get_filtered_deals_by_session_views deals, minimum
		excluded_deal_ids = Array.new()
		deals.find_each do |deal|
			break unless deals.count - excluded_deal_ids.count > minimum
			if session["dp#{deal.id}"].present? && session["dp#{deal.id}"] > 2
				excluded_deal_ids << deal.id
			end
		end
		return deals.where.not(id: excluded_deal_ids)
	end

	def get_max_number_of_deals deals, max, lat_lng
		unsorted_deals = Hash.new { |hash, key| hash[key] = [] }
		filtered_deals = get_deals_within_distance(deals, lat_lng)
		filtered_deals[:within].each { |x,y| unsorted_deals[x] << y }
  	deals = Array.new()
  	unsorted_deals.sort.map do |key,value|
  		deals.concat value
  	end
  	while deals.count > max do
  		deals.pop
  	end
  	while deals.count < max && filtered_deals[:outside].count > 0 do
  		deals << filtered_deals[:outside].shift[1]
  	end
  	return deals
  end

	def get_deals_within_distance deals, lat_lng
		deals_within = Array.new()
		deals_outside = Array.new()
		deals.find_each do |deal|
			shortest_distance = 10000
			deal.addresses.each do |address|
	  		distance = get_distance_from_address(address, lat_lng)
	  		if distance < shortest_distance
	  			if shortest_distance == 10000 && distance == -1
	  				shortest_distance = -1
	  			elsif distance != -1
		  			shortest_distance = distance
	  			end 
	  		end
		  end
  		if shortest_distance >= 0
	  		deals_within << [shortest_distance, deal]
	  	else
	  		deals_outside << [shortest_distance, deal]
	  	end
  	end
  	return Hash[within: deals_within, outside: deals_outside]
  end
end