module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:public_key] = user.public_key
  end

  def remember(user)
    user.remember
    cookies.permanent[:user_id] = user.public_key
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if session[:public_key]
      @current_user ||= User.where(public_key: session[:public_key]).first
    elsif cookies[:user_id]
      user = User.where(public_key: cookies[:user_id]).first
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end


  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:public_key)
    @current_user = nil
  end
end
