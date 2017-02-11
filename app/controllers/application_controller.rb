class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :set_defaults

  layout 'application'

  def index
    session[:deal_promos] = Hash.new { |hash, key| hash[key] = 0 }
  end

  # fix for websocket controller not being able to access cookies
  def the_cookies
    cookies
  end

  protected

  def current_user
    if @_current_user.present?
      return @_current_user
    end
    @_current_user = session[:current_account_id] && User.where(account_id: session[:current_account_id]).first
    return @_current_user
  end

  def signed_in?
    !!current_user
  end

  def sign_out
    @_current_user = session[:current_account_id] = nil
    reset_session
  end

  def is_admin?
    redirect_to root_path unless signed_in? && current_user.admin?
  end

  helper_method :current_user
  helper_method :signed_in?
  helper_method :sign_out

  def markdown_to_html(text)
    @_renderer ||= Redcarpet::Render::HTML.new({})
    @_markdown = Redcarpet::Markdown.new(@_renderer, extensions = {})
    @_markdown.render(text).html_safe
  end

  private

	# def layout_name
	# 	if params[:layout] == 0
	# 		false
	# 	else
	# 		'application'
	# 	end
	# end

  def set_defaults
    # session[:current_account_id] = 9 
    @title = "Idipops"
    @description = t "general.description"
  end
end
