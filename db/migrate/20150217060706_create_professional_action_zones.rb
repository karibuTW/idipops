class CreateProfessionalActionZones < ActiveRecord::Migration
  def change
    create_table :places_users do |t|
			t.belongs_to :user, index: true
      t.belongs_to :place, index: true
    end
  end
end
