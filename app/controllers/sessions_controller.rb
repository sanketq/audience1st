class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, %w(create)

  def new
    redirect_to customer_path(current_user) and return if logged_in?
    @page_title = "Login or Create Account"
    if (@gCheckoutInProgress)
      @cart = find_cart
    end
    @remember_me = true
    @email ||= params[:email]
  end

  def new_from_secret
    redirect_after_login(current_user) and return if logged_in?
  end

  def create
    create_session do |params|
      auth = request.env['omniauth.auth']
      if auth
        if logged_in?
          current_user.add_provider(auth) #if customer is logged in, add new auth to their account
          @u = current_user
        else
          # identity is a special case
          if params[:provider] == "identity"           
            # login/create using omniauth
            @u = Authorization.find_by(uid: params[:email], provider: params[:provider]).customer
          else
            # otherwise login using an existing auth or create a new account using a regular omniauth strategy
            @u = Authorization.find_or_create_user(auth)                               
          end
        end
      else
        # log in the old way and create an identity
        @u = Customer.authenticate(params[:email], params[:password])
        @u.bcrypt_password_storage(params[:password]) if @u && @u.errors.empty? && !@u.bcrypted? 
      end

      if @u.nil? || !@u.errors.empty?
        note_failed_signin(@u)
        @email = params[:email]
        @remember_me = params[:remember_me]
        render :action => :new
      end
      @u
    end
  end

  def create_from_secret
    create_session do |params|
    # If customer logged in using this mechanism, force them to change password.
      u = Customer.authenticate_from_secret_question(params[:email], params[:secret_question], params[:answer])
      if u.nil? || !u.errors.empty?
        note_failed_signin(u)
        if u.errors.include?(:no_secret_question)
          redirect_to login_path
        else
          redirect_to new_from_secret_session_path
        end
        return
      end
      u
    end
  end

  def destroy
    logout_killing_session!
    redirect_to login_path, :notice => "You have been logged out."
  end

  def temporarily_disable_admin
    session[:admin_disabled] = true
    redirect_to :back, :notice => "Switched to non-admin user view."
  end

  def reenable_admin
    if session.delete(:admin_disabled)
      flash[:notice] = "Admin view reestablished."
    end
    redirect_to :back
  end
  
  def failure
    redirect_to login_path, alert: "Sorry, incorrect Email/Password" 
  end

  protected
  

  # Track failed login attempts
  def note_failed_signin(user)
    flash[:alert] = "Couldn't log you in as '#{params[:email]}'"
    flash[:alert] << "because #{user.errors.as_html}" if user
    Rails.logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}: #{flash[:alert]}"
  end

end
