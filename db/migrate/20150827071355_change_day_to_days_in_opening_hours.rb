class ChangeDayToDaysInOpeningHours < ActiveRecord::Migration
  def change
  	rename_column :opening_hours, :day, :days
  	change_column :opening_hours, :days, :text
  	rename_column :opening_hours, :periods, :period
  	OpeningHour.update_all(days: [{"label"=>1, "value"=>false}, {"label"=>2, "value"=>false}, {"label"=>3, "value"=>false}, {"label"=>4, "value"=>false}, {"label"=>5, "value"=>true}, {"label"=>6, "value"=>false}, {"label"=>0, "value"=>false}, {"label"=>7, "value"=>false}], period: {"open"=>"2015-02-01T05:45:00.000Z", "close"=>"2015-02-01T11:45:00.000Z"})
  end
end
