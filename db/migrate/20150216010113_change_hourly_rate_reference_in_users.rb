class ChangeHourlyRateReferenceInUsers < ActiveRecord::Migration
  def change
  	remove_reference :users, :hourly_rate
  	add_column :users, :hourly_rate, :decimal, after: :quotation, precision: 8, scale: 2, default: -1
  end
end
