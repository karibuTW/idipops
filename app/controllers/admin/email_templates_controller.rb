class Admin::EmailTemplatesController < AdminController
	before_filter :set_template, only: [:show, :edit, :destroy,:update]

	def index
		@templates = EmailTemplate.order(created_at: :desc)
	end

	def edit
	end

	def show
	end

	def update
		if @template.update_attributes(template_params)
			flash[:notice] = "Email template #{params[:id]} update successfully"	
			redirect_to admin_email_templates_path
		else
			render :edit, error: @template.errors.full_messages
		end
	end

  def destroy
    @template.destroy
    flash[:notice] = "Email template #{params[:id]} supprimé"
    redirect_to admin_email_templates_path
  end

  private 

  def set_template
  	@template = EmailTemplate.find(params[:id])
  end

  def template_params
  	params.require(:email_template).permit(:name,:subject,:body)
  end
end