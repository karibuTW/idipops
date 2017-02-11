class PostCategorySerializer < BaseSerializer

	attributes :id,
		:name,
		:children

	def children
		ActiveModel::ArraySerializer.new(object.children.active.order(name: :asc), each_serializer: PostCategorySerializer).serializable_array
	end

end