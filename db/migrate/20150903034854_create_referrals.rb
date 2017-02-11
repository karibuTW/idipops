class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
    	t.integer :customer_id
    	t.integer :referrer_id
    	t.string :email
    	t.float :reward
    	t.string :workflow_state
    	t.datetime :accepted_at
      t.timestamps
    end
    add_column :users,:token,:string
  end
end
