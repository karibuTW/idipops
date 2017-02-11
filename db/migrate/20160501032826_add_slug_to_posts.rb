class AddSlugToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :slug, :string, index: true, unique: true, after: :title
  end
end
