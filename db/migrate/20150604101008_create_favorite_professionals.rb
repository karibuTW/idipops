class CreateFavoriteProfessionals < ActiveRecord::Migration
  def change
    create_table :users_favorite_professionals do |t|
      t.integer :user_id, index: true
      t.integer :professional_id, index: true
      t.timestamps
    end
  end
end
