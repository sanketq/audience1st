class NewsessionsController < ApplicationController
  def new
  end

  def create


    puts("here")
    authorization = Authorization.from_omniauth(env["omniauth.auth"])
    if (authorization && authorization.customer == nil)
      return redirect_to new_customer_path
    end
    puts(authorization)
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
