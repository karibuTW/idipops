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

class PlaceSerializer < BaseSerializer

  attributes :id,
             :postal_code,
             :place_name,
             :latitude,
             :longitude

end
