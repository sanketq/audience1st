class NewsessionsController < ApplicationController
  def new
  end

  def create
    authorization = Authorization.from_omniauth(env["omniauth.auth"])
    session[:user_id] = authorization.id
    redirect_to root_url, notice: "Signed in!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  def failure
    redirect_to root_url, alert: "Authentication failed, please try again."
  end
end