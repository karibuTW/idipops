# == Schema Information
#
# Table name: profile_views
#
#  id          	:integer          not null, primary key
#  user_id    	:integer          not null, index
#  latitude		:decimal(10,6)
#  longitude 	:decimal(10,6)
#  created_at  	:datetime
#  updated_at  	:datetime
#
class ProfileView < ActiveRecord::Base
	belongs_to :user
end