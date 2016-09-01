require 'bcrypt'

class PasswordResetsController < ApplicationController
  # before_action :get_user,   only: [:reset_password]
  # before_action :valid_user, only: [:reset_password]
  # before_action :check_expiration, only: [:reset_password]

  def request_password_reset
    if request.post?
      @user = User.where(email: params[:password_reset][:email].downcase).first
      if @user
        @user.create_reset_digest
        @user.send_password_reset_email
        flash[:info] = "Email sent with password reset instructions"
        redirect_to "/login"
      else
        flash.now[:error] = "Email address not found"
        render 'request_password_reset'
      end
    else
      render 'request_password_reset'
    end
  end

  def reset_password

    # Email test
    if !ValidationHandler.validate_email(params[:email])
      flash[:error] = Utilities::Message::MSG_INVALID_EMAIL
      Rails.logger.debug "reset_password: Invalid email"
      redirect_to "/login"
      return
    end

    # Test email length
    if params[:email].to_s.length > USER_EMAIL_MAX_LENGTH
      flash[:error] = Utilities::Message::MSG_EMAIL_MAX_LENGTH
      Rails.logger.debug "reset_password: Max Length reached"
      redirect_to "/login"
      return
    end

    # store email as lowercase!!!!!!!!!!!
    input_email = params[:email].to_s.downcase

    # Test unique email. Use lowercased email!!!
    @user = User.where(:email => input_email).first
    if @user.nil?
      flash[:error] = Utilities::Message::MSG_INVALID_EMAIL
      Rails.logger.debug "reset_password: Email not found"
      redirect_to "/login"
      return
    end

    unless (@user && @user.authenticated?(:reset, params[:id]))
      flash[:error] = Utilities::Message::MSG_INVALID_EMAIL
      Rails.logger.debug "reset_password: Reset not authenticated User[ " + @user.public_key.to_s + "] reset_token= " + params[:id]
      redirect_to "/login"
      return
    end

    if @user.password_reset_expired?
      Rails.logger.debug "reset_password: Reset expired User[ " + @user.public_key.to_s + "]"
      flash[:error] = "Password reset has expired."
      redirect_to "/login"
      return
    end

    if request.post?
      if params[:user][:password].empty? || params[:user][:password_confirmation].empty?
        Rails.logger.debug "reset_password Post: Password empty User[ " + @user.public_key.to_s + "]"
        flash[:error] = "Passwords can't be empty"
        redirect_to :controller => "PasswordResets", :action => "reset_password", :id => params[:id], :email => params[:email]
        return
      end

      if params[:user][:password] != params[:user][:password_confirmation]
        Rails.logger.debug "reset_password Post: Password not same User[ " + @user.public_key.to_s + "]"
        flash[:error] = "Passwords are not the same"
        redirect_to :controller => "PasswordResets", :action => "reset_password", :id => params[:id], :email => params[:email]
        return
      end

      @user.password_digest = BCrypt::Password.create(params[:user][:password])

      if !@user.save
        Rails.logger.debug "reset_password Post: User[" + @user.public_key.to_s + "] Error saving"
        flash[:error] = Utilities::Message::MSG_GENERAL_FAILURE
        redirect_to :controller => "PasswordResets", :action => "reset_password", :id => params[:id], :email => params[:email]
        return
      end

      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:info] = "Password has been reset."
      redirect_to "/login"

    end
  end

end
