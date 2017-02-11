# == Schema Information
#
# Table name: post_category_subsciptions
#
#  id                     :integer          not null, primary key
#  user_id                :integer 
#  post_category_id       :integer
#  last_read_at    :datetime
#  unread          :boolean          default(FALSE)
#  notified        :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#
class PostCategorySubscription < ActiveRecord::Base
	
	belongs_to :post_category
	belongs_to :user

end