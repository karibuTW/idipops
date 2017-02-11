class PostsController < ApplicationController

  def show
  	@post = Post.find_by(slug: params[:id]) || Post.find(params[:id])
  	if @post.present?
	    @title = @post.title
	    @description = @post.truncated_description
	  else
	  	@title = "Idipops"
	  	@description = t "general.description"
	  end
    render "application/index"
  end

end