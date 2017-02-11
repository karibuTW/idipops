class ProsController < ApplicationController

  def show
  	@pro = User.find_by(pretty_name: params[:id])
  	if @pro.present?
	    @title = "#{@pro.display_name}, #{Profession.find(@pro.primary_activity_id).name}"
	    @description = @pro.short_description
	  else
	  	@title = "Idipops"
	  	@description = ""
	  end
    render "application/index"
  end

end