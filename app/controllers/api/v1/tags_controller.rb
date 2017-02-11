class Api::V1::TagsController < ApiController

  def index

		if params.has_key?(:ex)
			search = params[:ex].gsub(/[!%&",.():;?]/,'')
			professions = Profession.at_depth(1).active.where( "name LIKE ?", "%#{search}%").order(name: :asc).map { |profession| {label: profession.name, type: 'profession', id: profession.id} }
			users = User.pro.where("company_name LIKE ?", "%#{search}%").group(:company_name).order(company_name: :asc).map { |user| { label: user.company_name, type: 'user', id: user.id} }
			tags = ActsAsTaggableOn::Tag.where("name like ?", "%#{search}%").order(name: :asc).limit(10).map { |tag| {label: tag.name, type: 'tag', id: tag.id} }
			result = professions.concat(users).concat(tags)
			if result.size == 0
				useless_strings = ["le", "la", "les", "un", "une", "de", "des", "du", "ce", "ces", "cet", "cette", "mon", "ton", "son","ma", "ta", "sa", "mes", "tes", "ses", "notre", "votre", "leur", "nos", "vos", "leurs", "quel", "quelle", "quels", "quelles", "à", "au", "aux"]
				keywords = search.split(' ') - useless_strings
				if keywords.size > 0
					professions = Profession.all.order(name: :asc)
					users = User.pro.order(company_name: :asc)
					tags = ActsAsTaggableOn::Tag.all.order(taggings_count: :desc)

					all_results = { professions: Array.new(), users: Array.new(), tags: Array.new() }
					keywords.each_with_index do |keyword, index|
						all_results[:professions].concat(professions.where( "name LIKE ?", "%#{keyword}%").map { |profession| {label: profession.name, type: 'profession', id: profession.id} })
						all_results[:users].concat(users.where("company_name LIKE ?", "%#{keyword}%").map { |user| { label: user.company_name, type: 'user', id: user.id} })
						all_results[:tags].concat(tags.where("name like ?", "%#{keyword}%").map { |tag| {label: tag.name, type: 'tag', id: tag.id} })
					end
					grouped_professions = all_results[:professions].group_by{ |item| item[:label] }
					grouped_users = all_results[:users].group_by{ |item| item[:label] }
					grouped_tags = all_results[:tags].group_by{ |item| item[:label] }
					profession_results_by_count = Array.new(keywords.size) { |e| e = Array.new() }
					user_results_by_count = Array.new(keywords.size) { |e| e = Array.new() }
					tag_results_by_count = Array.new(keywords.size) { |e| e = Array.new() }
					grouped_professions.each do |key, value|
						profession_results_by_count[value.size-1].push(value[0])
					end
					grouped_users.each do |key, value|
						user_results_by_count[value.size-1] << value[0]
					end
					grouped_tags.each do |key, value|
						tag_results_by_count[value.size-1] << value[0]
					end
					i = keywords.size-1
					while i >= 0
						result.concat(profession_results_by_count[i]).concat(user_results_by_count[i]).concat(tag_results_by_count[i])
						if result.size > 0
							break
						end
						i -= 1
					end
				end
			end
			render json: result.to_json, status: :ok
		elsif params.has_key?(:q)
      render json: ActsAsTaggableOn::Tag.where("name like ?", "%#{params[:q]}%").order(taggings_count: :desc).limit(10).map(&:name)
    elsif params.has_key?(:pids)
    	user_ids = User.with_activity(params[:pids]).pluck(:id)
    	tags = ActsAsTaggableOn::Tag.find_by_sql ["SELECT tags.*, taggings.tags_count AS count FROM `tags` JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count FROM `taggings` INNER JOIN users ON users.id = taggings.taggable_id WHERE (taggings.taggable_type = 'User' AND taggings.context = 'tags') AND (taggings.taggable_id IN (?)) GROUP BY taggings.tag_id HAVING COUNT(taggings.tag_id) > 0) AS taggings ON taggings.tag_id = tags.id ORDER BY taggings_count DESC LIMIT ?", user_ids, params[:limit].to_i]
    	render json: tags, status: :ok
    else
      render json: ActsAsTaggableOn::Tag.order(taggings_count: :desc).limit(10).map(&:name), status: :ok
	  end
  end

end