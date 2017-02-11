class Api::V1::PostsController < ApiController

	def create
		if signed_in? && current_user.user_type.present?
			post = Post.new(user: current_user)
			if params.has_key?(:featured_image) && params[:featured_image].present?
				post.featured_image = get_featured_image_file(params[:title], params[:featured_image])
			end
			tag_list = Array.new()
			params[:description].scan(/#\p{Alnum}+/) do |tag|
				tag.delete!("#")
				tag_list << tag
			end
			post.tag_list = tag_list
			params[:description].scan(/@\b[a-zA-Z0-9\u00C0-\u017F\-]+/) do |mention|
				mention.delete!("@")
				user_mentioned = User.find_by_pretty_name(mention)
				if user_mentioned.present?
					begin
						post_user_mention = PostUserMention.create(user: user_mentioned, post: post)
						post.post_user_mentions << post_user_mention
					rescue
						#Already exist
					end
				end
			end
			if post.update_attributes(post_params)
				if params[:post_sponsoring] == true
					pricing = Pricing.active("sponsored_post")
					if pricing.present? && pricing.active?
						price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
						if price_for_category.present?
							price = price_for_category.credit_amount
							if price > current_user.balance
								# Not enough money
							else
								transaction = CreditTransaction.create(user: current_user, credit_amount: -price, description: price_for_category.pricing.target)
								transaction.accept!
								PostSponsoring.create(post: post, credit_transaction: transaction, display_location: price_for_category.pricing.target, initial_impressions: 1000, remaining_impressions: 1000)
							end
						end
					end
				end
				post.send_notifications
				render json: post, status: :created, serializer: PostSerializer
			else
				render json: post.errors, status: :unprocessable_entity
			end
		else
			render json: nil, status: :unauthorized
		end
	end

	def update
		if signed_in?
			post = Post.find_by(id: params[:id])
			if post.present?
				if post.user.id == current_user.id
					if post.created_at > 2.days.ago
						if params.has_key?(:photo) && params[:photo].present?
	            photo = PostPhoto.create(post: post, attachment: photo_params[:photo])
	            if photo.present?
	              post.post_photos << photo
	            end
	            render json: nil, status: :ok
	          else
	          	if params.has_key?(:featured_image) && params[:featured_image].present?
	          		post.featured_image = get_featured_image_file(params[:title], params[:featured_image])
							end
							if post.update_attributes(post_params)
								if params.has_key?(:photo_ids_to_remove)
		              PostPhoto.delete(params[:photo_ids_to_remove])
		            end
		            if params[:post_sponsoring] == true
									pricing = Pricing.active("sponsored_post")
									if pricing.present? && pricing.active?
										price_for_category = pricing.price_for_categories.find_by(pricing_category: current_user.primary_activity.pricing_category)
										if price_for_category.present?
											price = price_for_category.credit_amount
											if price > current_user.balance
												# Not enough money
											else
												transaction = CreditTransaction.create(user: current_user, credit_amount: -price, description: price_for_category.pricing.target)
												transaction.accept!
												PostSponsoring.create(post: post, credit_transaction: transaction, display_location: price_for_category.pricing.target, initial_impressions: 1000, remaining_impressions: 1000)
											end
										end
									end
								end
								render json: post, status: :ok, serializer: PostSerializer
							else
								render json: post.errors, status: :unprocessable_entity
							end
						end
					else
						render json: nil, status: :forbidden
					end
				elsif params.has_key?(:report) && post.published?
					post.reporter_id = current_user.id
					post.report! params[:reject_reason]
					render json: nil, status: :ok
				else
					render json: nil, status: :unauthorized
				end
				
			else
				render json: nil, status: :not_found
			end
		else
			render json: nil, status: :unauthorized
		end
	end

	def index
		posts = Post.with_published_state
		if params.has_key?(:mine)
			if signed_in?
				posts = posts.where(user: current_user).order(created_at: :desc)
				render json: posts, status: :ok, each_serializer: PostListSerializer
			else
				render json: nil, status: :unauthorized
			end
		elsif params.has_key?(:subscriptions)
			if signed_in?
				posts = posts.where(user_id: current_user.post_author_subscriptions.pluck(:author_id)).union(posts.where(post_category_id: current_user.post_category_subscriptions.pluck(:post_category_id))).order(created_at: :desc)
				if current_user.premium_posts
					posts = posts.where(premium: true)
				end
				render json: posts, status: :ok, each_serializer: SubscribedPostListSerializer
			else
				render json: nil, status: :unauthorized
			end
		elsif params.has_key?(:favorite)
			if signed_in?
				posts = posts.where(id: current_user.favorite_posts.pluck(:post_id)).order(created_at: :desc)
				render json: posts, status: :ok, each_serializer: PostListSerializer
			else
				render json: nil, status: :unauthorized
			end
		elsif params.has_key?(:mentions)
			if signed_in?
				posts = posts.where(id: current_user.post_user_mentions.pluck(:post_id)).order(created_at: :desc)
				post_comments = PostComment.where(id: current_user.post_comment_user_mentions.pluck(:post_comment_id)).order(created_at: :desc)
				mentions = ActiveModel::ArraySerializer.new(posts, each_serializer: PostMentionSerializer, scope: view_context).serializable_array
				mentions += ActiveModel::ArraySerializer.new(post_comments, each_serializer: PostCommentMentionSerializer, scope: view_context).serializable_array
				render json: mentions.sort { |a,b| a[:created_at] <=> b[:created_at] }, status: :ok
			else
				render json: nil, status: :unauthorized
			end
		elsif params.has_key?(:proid)
			user = User.find_by_pretty_name(params[:proid])
			if user.present?
				posts = posts.where(user: user).order(created_at: :desc)
				render json: posts, status: :ok, each_serializer: PostListSerializer
			else
				render json: nil, status: :not_found
			end
		else
			if params[:category].present?
				posts = posts.where(post_category_id: params[:category])
			end
			if params[:premium].present?
				posts = posts.where(premium: true)
			end
			if params[:time].present?
				case params[:time]
				when "year" then
					time_threshold = 1.year.ago
				when "month" then
					time_threshold = 1.month.ago
				when "week" then
					time_threshold = 1.week.ago
				else
					time_threshold = Date.new(2016,1,1)
				end
				posts = posts.where("created_at > ?", time_threshold)
			end
			if params[:zone].present? && params[:latitude].present? && params[:longitude].present?
				pro_ids = Array.new()
				Post.joins(:user).where(users: {user_type: 'pro'}).pluck(:user_id).uniq.each do |pro_id|
					distance = get_shortest_distance_from_pro(User.find(pro_id), Geokit::LatLng.new(params[:latitude], params[:longitude]))
					if distance >= 0
						pro_ids << pro_id
					end
				end
				posts = posts.where(user_id: (pro_ids + Post.joins(:user).where(users: {user_type: 'particulier'}).pluck(:user_id).uniq))
			end
			if params[:search].present?
				search_param = "%#{params[:search]}%"
				posts = Post.tagged_with(params[:search], wild: true, any: true).union(Post.joins(:user).where("pretty_name LIKE ? OR company_name LIKE ? OR description LIKE ? OR title LIKE ?", search_param, search_param, search_param, search_param))
				# posts = posts.joins(:user).where('pretty_name LIKE ? OR company_name LIKE ?', search_param, search_param) + posts.tagged_with(params[:search], wild: true)
			end
			if params.has_key?(:sort)
				if params[:sort] == "most_seen"
					posts = posts.order(post_views_count: :desc)
				elsif params[:sort] == "most_liked"
					posts = posts.order(users_favorite_posts_count: :desc)
				else
					posts = posts.order(created_at: :desc)
				end
			end
			sponsored_ids = PostSponsoring.where(display_location: "sponsored_post").where('remaining_impressions > 0').pluck(:post_id).uniq
			sponsored_posts = Array.new()
			if (!params.has_key?(:page) || params[:page].to_i == 1) && sponsored_ids.count > 0
				max = 3
				posts.each_with_index do |post, index|
					if sponsored_ids.include?(post.id)
						sponsored_posts << post
						selected_post = PostSponsoring.where(display_location: "sponsored_post", post: post).where('remaining_impressions > 0').first
						if selected_post.present?
							selected_post.remaining_impressions = selected_post.remaining_impressions - 1
							selected_post.save
						end
						max = max - 1
					end
					break unless max > 0
				end
			end
			posts = posts.paginate(page: params[:page], per_page: 15)
			posts = posts - sponsored_posts
			render json: { sponsored: ActiveModel::ArraySerializer.new(sponsored_posts, each_serializer: PostListSerializer, scope: view_context) , regular: ActiveModel::ArraySerializer.new(posts, each_serializer: PostListSerializer, scope: view_context) }, status: :ok, each_serializer: PostListSerializer
		end
	end

	def show
		post = Post.find_by(slug: params[:id]) || Post.find(params[:id])
		if post.present?
			if (signed_in? && current_user != post.user) || !signed_in?
				post_view = PostView.new(post: post)
				if params.has_key?(:latitude) && params.has_key?(:longitude)
					post_view.latitude = params[:latitude]
					post_view.longitude = params[:longitude]
				end
				post_view.save
			end
			if signed_in?
				post.mark_read(current_user, current_user == post.user)
			end
			render json: post, status: :ok, serializer: PostSerializer
		else
			render json: nil, status: :not_found
		end
	end

	private

	def get_featured_image_file title, featured_image
		image_content = Base64.decode64(featured_image[featured_image.index(',') .. -1])
		extension = featured_image.split(";")[0].split("/")[1]
		tmp_file = "#{Rails.root}/tmp/#{title.parameterize}.#{extension}"
		f = File.open(tmp_file, 'wb')
		f.write image_content
		f.close
		f
	end

	def post_params
		params.permit(
      :title, 
      :post_type,
      :description,
      :post_category_id
    )
	end

  def photo_params
    params.permit(:photo)
  end

end