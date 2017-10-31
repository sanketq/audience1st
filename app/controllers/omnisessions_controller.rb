class OmnisessionsController < ApplicationController
  def new
    redirect_to customer_path(current_user) and return if logged_in?
    @page_title = "Login or Create Account"
    if (@gCheckoutInProgress)
      @cart = find_cart
    end
    @remember_me = true
    @email ||= params[:email]
  end

  def create
    authorization = Authorization.from_omniauth(env["omniauth.auth"])
    if (authorization && authorization.customer == nil)
      redirect_to new_customer_path({:authorization => authorization}) and return
    end
    #do we need this?
    #session[:authorization_id] = authorization.id
    u = authorization.customer
    @current_user = u
    create_session(u)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  def failure
    redirect_to root_url, alert: "Authentication failed, please try again."
  end
end
