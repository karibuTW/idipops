# == Schema Information
#
# Table name: professions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  description                   :text
#  active                        :boolean
#  ancestry                      :string(255)
#  ancestry_depth                :integer          default(0)
#  quotation_request_template_id :integer
#  pricing_category_id           :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#  image_uid                     :string(255)
#

class ProfessionSerializer < BaseSerializer

	attributes :id,
		:name,
		:description,
		:image_uid,
		:children

	def children
		ActiveModel::ArraySerializer.new(object.children.active.order(name: :asc), each_serializer: ProfessionSerializer).serializable_array
	end

end
