class UsersController < ApplicationController

  def dashboard
    @title = "Profil"
  end

  def edit
    @title = "Modifiez votre profil"
  end

end