class CreatePostSponsorings < ActiveRecord::Migration
  def change
    create_table :post_sponsorings do |t|
      t.references :post, index: true, foreign_key: true
      t.references :credit_transaction, index: true, foreign_key: true
      t.integer :initial_impressions, default: 0
      t.integer :remaining_impressions, default: 0
      t.string :display_location
      t.timestamps
    end
  end
end
