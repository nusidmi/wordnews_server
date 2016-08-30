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
    redirect_to :action => "new"
  end

end
