# == Schema Information
#
# Table name: places
#
#  id           :integer          not null, primary key
#  country_code :string(255)
#  postal_code  :string(255)
#  place_name   :string(255)
#  admin_name1  :string(255)
#  admin_code1  :string(255)
#  admin_name2  :string(255)
#  admin_code2  :string(255)
#  admin_code3  :string(255)
#  latitude     :decimal(10, 6)
#  longitude    :decimal(10, 6)
#  geo_point_2d :string(255)
#  geo_shape    :text
#

class Place < ActiveRecord::Base
	has_many :users
	has_and_belongs_to_many :professionals, class_name: "User"
	has_many :classified_ads

	scope :fr, -> { where(country_code: 'FR') }
	scope :departement_starts_with, -> (name) { where("admin_name2 like ?", "#{name}%")}
	scope :name_starts_with, -> (name) { where("place_name like ?", "#{name}%")}
	scope :code_starts_with, -> (code) { where("postal_code like ?", "#{code}%")}
	scope :starts_with, -> (search) { where("postal_code like ? or place_name like ?", "#{search}%", "#{search}%")}
	scope :departement_code_starts_with, -> (search) { where("postal_code like ? or admin_name2 like ?", "#{search}%", "#{search}%")}

	def formatted_name
		return "#{place_name}, #{postal_code}"
	end
end
