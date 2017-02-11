class CreateSlugsForExistingPosts < ActiveRecord::Migration
  def up
    Post.all.each do |post|
	  	post.create_slug
	  	post.save
	  end
  end

  def down
    Post.all.each do |post|
	  	post.slug = nil
	  	post.save
	  end
  end
end
