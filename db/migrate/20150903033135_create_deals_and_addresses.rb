class CreateDealsAndAddresses < ActiveRecord::Migration
  def change
    create_table :addresses_deals do |t|
      t.references :deal, index: true
      t.references :address, index: true
    end
    remove_reference :deals, :address, index: true, after: :user_id
  end
end
