class IdentitiesController < ApplicationController
    
  def new
    @identity = env['omniauth.identity']#request.env['omniauth.auth']  
  end

  def create
  end

  def destroy
    session[:user_id] = nil #this may not work/be necessary
    redirect_to root_url, notice: "Signed out!"
  end

  def failure
    redirect_to root_url, alert: "Log In failed, please try again."
  end
end
