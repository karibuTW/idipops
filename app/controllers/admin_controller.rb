class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_filter :is_admin?

  layout 'admin'

end