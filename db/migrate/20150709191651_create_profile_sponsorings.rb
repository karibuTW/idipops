class CreateProfileSponsorings < ActiveRecord::Migration
  def change
    create_table :profile_sponsorings do |t|
      t.references :credit_transaction, index: true
      t.references :user, index: true
      t.integer :initial_impressions, default: 0
      t.integer :remaining_impressions, default: 0
      t.string :display_location
      t.timestamps
    end
  end
end
