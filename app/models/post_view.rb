# == Schema Information
#
# Table name: post_views
#
#  id          	:integer          not null, primary key
#  post_id    	:integer          not null, index
#  latitude		:decimal(10,6)
#  longitude 	:decimal(10,6)
#  created_at  	:datetime
#  updated_at  	:datetime
#
class PostView < ActiveRecord::Base
	belongs_to :post, counter_cache: true, touch: true
end