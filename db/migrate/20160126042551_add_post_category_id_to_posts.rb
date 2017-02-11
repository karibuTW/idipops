class AddPostCategoryIdToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :post_category, index: true, foreign_key: true
  end
end
