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

  def get_if_translate
    # @user_name = params[:name]
    #
    # @user = User.where(:user_name => @user_name).first
    # if @user.blank? #no user
    #   Utilities::UserHandler::make_user @user_name
    #   @user = User.where(:user_name => @user_name).first
    # end
    #
    # @ifTranslate = @user.if_translate
    # @result = Hash.new
    # @result['if_translate'] = @ifTranslate
    #
    # respond_to do |format|
    #   format.html { render :layout => false }
    # end

    user_name = params[:name]

    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    # Validate userID
    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    @user = User.where(:user_name => user_name).first
    if @user.nil?
      Rails.logger.warn "get_if_translate: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    result['if_translate'] = @user.if_translate
    result['msg'] = Utilities::Message::MSG_OK
    return render json: result
  end

  # What is this for?
  def get_suggest_url
    result = Hash.new

    #@result['url'] = "http://zhaoyue.com/cn"   # What is this for?
    result['url'] = ''
    result['msg'] = Utilities::Message::MSG_OK
    return render json: result
  end

  def display_history
    # @user_name = params[:name]
    # @user = User.where(:user_name => @user_name).first
    # if @user.blank? #no user
    #   Utilities::UserHandler::make_user @user_name
    #   @user = User.where(:user_name => @user_name).first
    # end
    #
    # find_to_learn_query = 'user_id = ' + @user.id.to_s + ' and frequency = 0'
    # find_learnt_query = 'user_id = ' + @user.id.to_s + ' and frequency > 0'
    # meaning_to_learn_List = History.all(:select => 'meaning_id', :conditions => [find_to_learn_query])
    # @words_to_learn = []
    # if meaning_to_learn_List.length !=0
    #   for meaning in meaning_to_learn_List
    #     temp = Meaning.find(meaning.meaning_id)
    #     @words_to_learn.push(temp)
    #   end
    # end
    #
    # meaning_learnt_list = History.all(:select => 'meaning_id', :conditions => [find_learnt_query])
    # @words_learnt = []
    # if meaning_learnt_list.length !=0
    #   meaning_learnt_list.each do |meaning|
    #     temp = ChineseWords.joins(:english_words)
    #             .select('english_meaning, chinese_meaning, meanings.id, english_words_id, chinese_words_id, pronunciation')
    #     .where('meanings.id = ?', meaning.meaning_id).first
    #     @words_learnt.push(temp)
    #   end
    # end

    user_name = params[:name]
    @user = nil
    @msg = Utilities::Message::MSG_GENERAL_FAILURE
    # Validate userID
    if !UserHandler.validate_userID( user_name )
      @msg = Utilities::Message::MSG_INVALID_PARA
      return render status: :bad_request

    end

    @user = User.where(:user_name => user_name).first
    if @user.nil?
      Rails.logger.warn "display_history: User[" + user_name.to_s + "] not found"
      @msg = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render status: :bad_request
    end

    @msg = Utilities::Message::MSG_OK

    find_to_learn_query = 'user_id = ' + @user.id.to_s + ' and frequency = 0'
    find_learnt_query = 'user_id = ' + @user.id.to_s + ' and frequency > 0'
    meaning_to_learn_List = History.all(:select => 'meaning_id', :conditions => [find_to_learn_query])
    @words_to_learn = []
    if meaning_to_learn_List.length !=0
      for meaning in meaning_to_learn_List
        temp = Meaning.find(meaning.meaning_id)
        @words_to_learn.push(temp)
      end
    end

    meaning_learnt_list = History.all(:select => 'meaning_id', :conditions => [find_learnt_query])
    @words_learnt = []
    if meaning_learnt_list.length !=0
      meaning_learnt_list.each do |meaning|
        temp = ChineseWords.joins(:english_words)
                .select('english_meaning, chinese_meaning, meanings.id, english_words_id, chinese_words_id, pronunciation')
        .where('meanings.id = ?', meaning.meaning_id).first
        @words_learnt.push(temp)
      end
    end

    respond_to do |format|
      format.html # displayHistory.html.erb
      #format.json { render json: @words_learnt }
    end
  end

  def settings
    # @user_name = params[:name]
    # @find_user_query = "user_name = '" + @user_name+"'"
    # @user = User.find(:first, :conditions => [ @find_user_query ])
    #
    # respond_to do |format|
    #   format.html #{ render :layout => false }# displayHistory.html.erb
    #   format.json { render json: @user }
    # end

    user_name = params[:name]
    @user = nil
    @msg = Utilities::Message::MSG_GENERAL_FAILURE
    # Validate userID
    if !UserHandler.validate_userID( user_name )
      @msg = Utilities::Message::MSG_INVALID_PARA
      return render status: :bad_request
    end

    @user = User.where(:user_name => user_name).first
    if @user.nil?
      Rails.logger.warn "settings: User[" + user_name.to_s + "] not found"
      @msg = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render status: :bad_request
    end

    respond_to do |format|
      format.html #{ render :layout => false }# displayHistory.html.erb
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

    user_name = params[:name]
    @user = nil
    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    # Validate userID
    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    @user = User.where(:user_name => user_name).first
    if @user.nil?
      Rails.logger.warn "settings: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    @time_elapsed = params[:time]
    @move = params[:move]

    #puts "Log: User " + @user.id.to_s + ":" + @time_elapsed.to_s + ":" + @move.to_s
    USER_ACTION_LOGGER.info( "Log: User[" + user_name + "], Elasped_t:" + @time_elapsed.to_s + ", Action:" + @move.to_s )

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


 
  # This is a temporal solution to obtain user id, and partially duplicate with /getNumber
  # TODO: refine user account management
  def get_id_by_username
    if !params[:user_name].present?
       respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA },
                      status: :bad_request}
      end
      return
    end
    
    @user_name = params[:user_name]
    user = User.where(:user_name => @user_name).first
    if user.blank? #no user
      newUser = User.new
      newUser.user_name = @user_name
      newUser.if_translate = 1
      newUser.translate_categories = '1,2,3,4' # the default will be translate all # TODO what does this do?
      newUser.save
      user = newUser
    end
    puts user.id
    
    respond_to do |format|
      format.json { render json: {user_id: user.id, msg: Utilities::Message::MSG_OK },
                    status: :ok}
    end
  end



end
