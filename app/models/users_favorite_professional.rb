# == Schema Information
#
# Table name: users_favorite_professionals
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  professional_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class UsersFavoriteProfessional < ActiveRecord::Base
	belongs_to :user
	belongs_to :favorite_professional, class_name: "User", foreign_key: "professional_id"

end
