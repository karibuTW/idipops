class AddPaymentInfoToUserS < ActiveRecord::Migration
  def change
    add_column :users, :quotation, :tinyint, after: :secondary_activity_id
    add_column :users, :prestation, :tinyint, after: :secondary_activity_id
    add_reference :users, :hourly_rate, index: true, after: :secondary_activity_id
  end
end
