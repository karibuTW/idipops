class AddAddressToDeals < ActiveRecord::Migration
  def change
    add_reference :deals, :address, index: true, after: :user_id

    Deal.all.each { |deal|
    	deal.address = deal.user.addresses.first
    	deal.save
    }
  end
end
