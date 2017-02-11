class Admin::UsersController < AdminController
  before_action :find_user, only: [:show, :add_credits, :subtract_credits]
  def index
    @users = User.load_or_search(params).order(:id).paginate(page: params[:page], per_page: 50)
  end

  def show
    if @user.is_pro?
      @reviews = @user.pro_reviews
    end
  end

  def update
    user = User.find_by(id: params[:id])
    if user
      if params[:active]
        if params[:active] == "1"
          user.activate!
        else
          user.deactivate!
        end
        flash[:notice] = user.active? ? "User successfully activated." : "User successfully deactivated."
      elsif params[:admin]
        if current_user != user
          if user.update_attributes(admin: params[:admin])
            flash[:notice] = user.admin? ? "Admin rights given to user." : "Admin rights removed from user."
          else
            flash[:alert] = "Unable to update user!"
          end
        else
          flash[:alert] = "Cannot remove your own admin rights!"
        end
      end
    else
      flash[:alert] = "User not found!"
    end
    redirect_to admin_user_path(user)
  end

  def subtract_credits
    response = {}
    if @user.subtract_credits params[:points].to_i
      response[:success] = true;
      response[:message] = 'Subtract credits successfully'
    else
      response[:success] = false;
      response[:message] = 'Subtract credits failed'
    end
    response[:points] = @user.balance
    render json: response
  end

  def add_credits
    response = {}
    if @user.add_credits params[:points].to_i
      response[:success] = true
      response[:message] = 'Add Credits successfully'
    else
      response[:success] = false
      response[:message] = 'Add Credits failed'
    end
    response[:points] = @user.balance
    render json: response
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
