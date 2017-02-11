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

class Address < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :deals
  has_many :opening_hours, dependent: :destroy
  # validates :land_phone, presence: true, unless: ->(address){address.mobile_phone.present? || address.user.user_type != 'pro'}, on: :update
  # validates :mobile_phone, presence: true, unless: ->(address){address.land_phone.present? || address.user.user_type != 'pro'}, on: :update

  # Bulk update and save opening hours for an address
	#
  # Input format:
  # [
  #   {
  #      [id: 1, ] // Update if persisted
  #      day: <wday>,
  #      pediods: [
  #         { // 1st period
  #            open: {
  #               hour: 7,
  #               minute: 0
  #            },
  #            close: {
  #               hour: 11,
  #               minute: 0
  #            }
  #        },
  #        {
  #           // 2nd period
  #        }
  #    ]
  #    },
  #    // Another day
  # ]
  #
  #
  def bulk_update_opening_hours(data)
    current_oh_ids = self.opening_hours.delete_all
    data.each do |oh_params|
      next if oh_params[:period].blank? || oh_params[:days].blank?
      oh_params = oh_params.with_indifferent_access
      oh = self.opening_hours.new
      oh.days = oh_params[:days]
      oh.period = oh_params[:period]
      oh.save
    end
  end
end
