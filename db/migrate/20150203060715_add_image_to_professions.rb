class AddImageToProfessions < ActiveRecord::Migration
  def change
    add_column :professions, :image_uid, :string
  end
end
