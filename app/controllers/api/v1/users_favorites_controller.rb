class Api::V1::UsersFavoritesController < ApiController

	def index
    if signed_in?
      posts = ActiveModel::ArraySerializer.new(current_user.users_favorite_posts, each_serializer: UsersCombinedFavoritePostSerializer).serializable_array
      pros = ActiveModel::ArraySerializer.new(current_user.users_favorite_professionals, each_serializer: UsersCombinedFavoriteProfessionalSerializer).serializable_array
      deals = ActiveModel::ArraySerializer.new(current_user.users_favorite_deals, each_serializer: UsersCombinedFavoriteDealSerializer).serializable_array
    	render json: (posts + pros + deals).sort { |a,b| b[:created_at] <=> a[:created_at] }, status: :ok
    else
    	render json: nil, status: :unauthorized
    end
  end

end