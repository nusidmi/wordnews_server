require 'bcrypt'

class UsersController < ApplicationController
  #include UserHandler
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    #@user = User.where(:user_name => @user_name).first
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end


  # not implemented yet
  def settings
    public_key = params[:user_id]
    @user = nil
    @msg = Utilities::Message::MSG_GENERAL_FAILURE
    # Validate userID
    if !UserHandler.validate_public_key( public_key )
      @msg = Utilities::Message::MSG_INVALID_PARA
      return render status: :bad_request
    end

    @user = User.where(:public_key => public_key).first
    if @user.nil?
      Rails.logger.warn "settings: User[" + public_key.to_s + "] not found"
      @msg = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render status: :bad_request
    end

    respond_to do |format|
      format.html #  settings.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end



  # TODO think about deprecating this.
  def log
    result = Hash.new

    if !params[:user_id].present? or !params[:time_elapsed].present? or\
       !params[:activity].present?
       result['mgs'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end
    
    puts Utilities::AnnotationUtil.get_pronunciation('中国')
    
    public_key = params[:user_id]
    
    # Validate userID
    if !UserHandler.validate_public_key( public_key )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    @user = User.where(:public_key => public_key).first
    if @user.nil?
      Rails.logger.warn "settings: User[" + public_key.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    if params[:detail].present?
      USER_ACTION_LOGGER.info( "Log: User[" + public_key.to_s + "], Elasped_t:" + params[:time_elapsed].to_s + ", Action:" + params[:activity].to_s + ", Detail: " + params[:detail])
    else
      USER_ACTION_LOGGER.info( "Log: User[" + public_key.to_s + "], Elasped_t:" + params[:time_elapsed].to_s + ", Action:" + params[:activity].to_s)
    end

    result['msg'] = Utilities::Message::MSG_OK
    return render json: result
  end
  

  def validate_google_id_token
    email = Utilities::UserHandler::email_if_google_id_valid(params[:id_token])
    if email.blank?
      logger.info('No valid identity token present')
      render status: 401, nothing: true
    else
	  result = Hash.new
	  result['email'] = email
      render status: 200, json: result
    end
  end



  def create_new_user
    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    user = UserHandler.create_new_user()
    if !user.nil?
      result['user'] = Hash.new
      result['user']['user_id'] = user.public_key.to_i
      result['user']['rank'] = user.rank
      result['user']['score'] = user.score
      result['msg'] =  Utilities::Message::MSG_OK
    else
      result['msg'] =  Utilities::Message::MSG_CREATE_FAILURE
      return render json: result, status: :internal_server_error
    end

    render json: result
  end

  def sign_up_new_user
    if request.get?
      public_key = params[:user_id]

      @user = User.new()
      if !UserHandler.validate_public_key( public_key )
        flash[:error] = Utilities::Message::MSG_INVALID_PARA
        return
      end

      user_check = User.where(:public_key => public_key).first
      if user_check.nil?
        Rails.logger.warn "sign_up_new_user: User[" + public_key.to_s + "] not found"
        flash[:error] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
        return
      end

      @user.public_key = public_key
      @pub_key = public_key
    else
      user_param = params[:user]
      public_key = user_param[:public_key]

      @user = User.new()
      if !UserHandler.validate_public_key( public_key )
        flash[:error] = Utilities::Message::MSG_INVALID_PARA
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      user_check = User.where(:public_key => public_key).first
      if user_check.nil?
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] not found"
        flash[:error] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      if ( !user_param[:user_name].present? || !user_param[:email].present? \
          || !user_param[:password].present? || !user_param[:password_confirmation].present? )
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] missing parameters"
        flash[:error] = Utilities::Message::MSG_MISSING_SIGN_UP_PARAMS
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      # Test user_name length
      if user_param[:user_name].to_s.length > USER_NAME_MAX_LENGTH
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Name;[" + user_param[:user_name].to_s + "] exceed name length"
        flash[:error] = Utilities::Message::MSG_USER_NAME_MAX_LENGTH
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      # Email test
      if !ValidationHandler.validate_email(user_param[:email])
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Email:[" + user_param[:email].to_s + "] Invalid"
        flash[:error] = Utilities::Message::MSG_INVALID_EMAIL
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      # Test email length
      if user_param[:email].to_s.length > USER_EMAIL_MAX_LENGTH
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Email:[" + user_param[:email].to_s + "] exceed max length"
        flash[:error] = Utilities::Message::MSG_EMAIL_MAX_LENGTH
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      # store email as lowercase!!!!!!!!!!!
      input_email = user_param[:email].to_s.downcase

      # Test unique email. Use lowercased email!!!
      user_email_test = User.where(:email => input_email).first
      if !user_email_test.nil?
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Email:[" + user_param[:email].to_s + "] already registered"
        flash[:error] = Utilities::Message::MSG_EMAIL_DUPLICATE
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      # Test if password and password_confirmation is same
      if user_param[:password] != user_param[:password_confirmation]
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Password is not same"
        flash[:error] = Utilities::Message::MSG_PASSWORD_IS_NOT_SAME
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      user_check.user_name = user_param[:user_name].to_s
      user_check.email = input_email
      user_check.password_digest = BCrypt::Password.create(user_param[:password])
      user_check.registered_at = Time.now()

      if !user_check.save
        Rails.logger.debug "sign_up_new_user Post: User[" + public_key.to_s + "] Error saving"
        flash[:error] = Utilities::Message::MSG_GENERAL_FAILURE
        redirect_to :action => "sign_up_new_user", :user_id => public_key
        return
      end

      log_in user_check
      redirect_to :action => "sign_up_complete"
    end
  end

  def sign_up_complete
  end
end

