# == Schema Information
#
# Table name: opening_hours
#
#  id         :integer          not null, primary key
#  address_id :integer
#  day        :integer
#  periods    :text
#  created_at :datetime
#  updated_at :datetime
#

class OpeningHour < ActiveRecord::Base
  DAYS = (0..7).to_a
  serialize :days, JSON
  serialize :period, JSON
  belongs_to :address

  validates_presence_of :address, :days, :period

  validates_each :days do |record, attr, days_value|
    _errors = ''
    if days_value
      days_value.each do |day|
        day = day.with_indifferent_access
        if day[:label].blank? || !DAYS.include?(day[:label])
          _errors << "day label is not correct or missing."
        end
        #if day[:value].blank?
        #  _errors << "day value is not correct or missing."
        #end
      end
    end
    record.errors.add(:days, _errors) unless _errors.empty?
  end

  validates_each :period do |record, attr, period|
    _errors = ''
    period = period.with_indifferent_access
    if period[:open].blank? ||
      Time.zone.parse(period[:open]).blank?
      _errors << "open time is not correct or missing."
    end
    if period[:close].blank? ||
      Time.zone.parse(period[:close]).blank?
      _errors << "close time is not correct or missing."
    end
    record.errors.add(:period, _errors) unless _errors.empty?
  end

end
