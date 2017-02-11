# == Schema Information
#
# Table name: addresses
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  formatted_address :text
#  place_id          :string(255)
#  latitude          :decimal(10, 6)
#  longitude         :decimal(10, 6)
#  action_range      :integer          default(50)
#  created_at        :datetime
#  updated_at        :datetime
#  land_phone        :string(255)
#  mobile_phone      :string(255)
#  fax               :string(255)
#

class AddressSerializer < BaseSerializer

  attributes :id,
             :user_id,
             :place_id,
             :formatted_address,
             :latitude,
             :longitude,
             :land_phone,
             :mobile_phone,
             :fax,
             :action_range,
             :opening_hours

  def opening_hours
    wdays = (0..6).to_a
    parsed_ohs = []
    worked_wdays = []
    object.opening_hours.each do |opening_hour|
      parsed_opening_hour = {}
      parsed_opening_hour[:id] = opening_hour.id
      parsed_opening_hour[:days] =  opening_hour.days
      parsed_opening_hour[:period] = opening_hour.period
      parsed_ohs << parsed_opening_hour
    end
    parsed_ohs
  end
end
