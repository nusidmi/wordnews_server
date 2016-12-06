require 'bcrypt'

class SessionsController < ApplicationController
  def new
  end

  def create
    if !params[:session][:email].present? || !params[:session][:password].present?
      Rails.logger.debug "login Post: Missing param"
      flash[:error] = Utilities::Message::MSG_MISSING_LOGIN_PARAMS
      return render 'new'
    end

    # Email test
    if !ValidationHandler.validate_email(params[:session][:email])
      Rails.logger.debug "login Post: Email:[" + params[:session][:email].to_s + "] Invalid"
      flash[:error] = Utilities::Message::MSG_INVALID_EMAIL
      return render 'new'
    end

    # Test email length
    if params[:session][:email].to_s.length > USER_EMAIL_MAX_LENGTH
      Rails.logger.debug "login Post: Email:[" + params[:session][:email].to_s + "] exceed max length"
      flash[:error] = Utilities::Message::MSG_EMAIL_MAX_LENGTH
      return render 'new'
    end

    # store email as lowercase!!!!!!!!!!!
    input_email = params[:session][:email].to_s.downcase

    # Test unique email. Use lowercased email!!!
    user_email_test = User.where(:email => input_email).first
    if user_email_test.nil?
      Rails.logger.debug "login Post: Email:[" + params[:session][:email].to_s + "] Email not registered"
      flash[:error] = Utilities::Message::MSG_EMAIL_NOT_FOUND
      return render 'new'
    end

    test_password_digest = BCrypt::Password.new(user_email_test.password_digest)
    if test_password_digest != params[:session][:password]
      Rails.logger.debug "login Post: Email:[" + params[:session][:email].to_s + "] Password not correct"
      flash[:error] = Utilities::Message::MSG_EMAIL_PASSWORD_NOT_CORRECT
      return render 'new'
    end

    log_in user_email_test
    remember user_email_test

    redirect_to :action => "login_complete"
  end

  def login_complete
  end

  def logout
    log_out if logged_in?
    flash[:info] = "You have successfully logged out"
    redirect_to :action => "new"
  end

  def authenticate_social

    params =  env["omniauth.params"]

    status = params["status"].to_s

    auth = env["omniauth.auth"]

    if params["status"].nil?
      flash[:error] = Utilities::Message::MSG_INVALID_PARA
      redirect_to :action => "new", :controller => "sessions"
      return
    end

    if status == "signup"
      # User is attempting to SIGNUP using social account. If the social account is not associated with any user,
      # save the info to database.
      public_key = params["user_id"]

      if !UserHandler.validate_public_key( public_key )
        flash[:error] = Utilities::Message::MSG_INVALID_PARA
        Rails.logger.debug "authenticate_social: [SIGNUP] Public key not found"
        redirect_to :action => "sign_up_new_user", :user_id => public_key, :controller => "users"
        return
      end

      user_check = User.where(:public_key => public_key).first
      if user_check.nil?
        Rails.logger.debug "authenticate_social: [SIGNUP] User[" + public_key.to_s + "] not found"
        flash[:error] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
        redirect_to :action => "sign_up_new_user", :user_id => public_key, :controller => "users"
        return
      end
      user_id = user_check.id

      @user_ext_login = UserExternalLogin.find_with_omniauth(auth)

      if !@user_ext_login.nil?
        Rails.logger.debug "authenticate_social: [SIGNUP] User[" + public_key.to_s + "]. This social account has already registered!"
        flash[:info] = Utilities::Message::MSG_SOCIAL_SIGNUP_ACCOUNT_ALREADY_REGISTERED
        redirect_to :action => "sign_up_new_user", :user_id => public_key, :controller => "users"
        return
      end

      @user_ext_login = UserExternalLogin.create_with_omniauth(auth)

      @user_ext_login.user_id = user_id
      @user_ext_login.save

      redirect_to :action => "sign_up_complete", :controller => "users"
      return

    elsif status == "login"
      # User is attempting to LOGIN using social account. If the social account is not associated with any user,
      # fail them.

      @user_ext_login = UserExternalLogin.find_with_omniauth(auth)

      if @user_ext_login.nil?
        Rails.logger.debug "authenticate_social: [LOGIN] User[" + public_key.to_s + "]. This social account has not registered!"
        flash[:info] = Utilities::Message::MSG_SOCIAL_LOGIN_ACCOUNT_NOT_REGISTERED
        return redirect_to :action => "new", :controller => "sessions"
      end

      user = User.where(:id => @user_ext_login.user_id).first
      if user.nil?
        Rails.logger.debug "authenticate_social: [LOGIN] UserID[" + @user_ext_login.user_id.to_s + "] not found"
        flash[:error] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
        return redirect_to :action => "new", :controller => "sessions"
      end

      log_in user
      remember user

      return redirect_to :action => "login_complete"

    end

    # Does not fall into login/ sign up status. Some stray request? Force user back to login
    return redirect_to :action => "new", :controller => "sessions"

  end

  def authenticate_social_failure
    flash[:error] = Utilities::Message::MSG_SOCIAL_AUTHENTICATE_ERROR
    return redirect_to :action => "new", :controller => "sessions"
  end

end
