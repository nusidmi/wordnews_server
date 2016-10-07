
class FacebookController < ApplicationController

  def share_most_annotated
    result = Hash.new

    if !params[:user_id].present?
      Rails.logger.debug "share_most_annotated Post: Missing param"
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    public_key = params[:user_id]

    # Validate userID
    if !UserHandler.validate_public_key( public_key )
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] invalid param"
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    user = User.where(:public_key => public_key).first
    id = user.id
    if id.nil?
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    @user_ext_login = UserExternalLogin.find_with_user_id_and_provider(id, "facebook");
    if @user_ext_login.nil?
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] has not registered a facebook account"
      result['msg'] = Utilities::Message::MSG_SOCIAL_LOGIN_ACCOUNT_NOT_REGISTERED
      return render json: result, status: :bad_request
    end

    # default to some value
    query_str = ""
    query_str += params[:lang].present? ? ("lang=" + params[:lang].to_s) : "lang=zh_CN"
    query_str += params[:num].present? ? ("&num=" + params[:num].to_s) : "&num=10"
    query_str += params[:from_date].present? ? ("&from_date=" + params[:from_date].to_s) : ""
    query_str += params[:to_date].present? ? ("&to_date=" + params[:to_date].to_s) : ""

    @link = request.protocol + request.host_with_port + "/show_most_annotated_urls?" + query_str

    @graph = Koala::Facebook::API.new(@user_ext_login.oauth_token)
    @graph.put_wall_post("Go checkout annotated these articles!", {:name => "Most annotated articles", :link => @link })


    # give credits to user
    if user.facebook_share_count<MAX_FB_SHARE_WITH_CREDITS
      user.score += Utilities::UserLevel.get_score(:sns_share)
      user.rank += Utilities::UserLevel.upgrade_rank(user)
      user.update_attributes(facebook_share_count: user.facebook_share_count+1, 
                             score: user.score, rank: user.rank)
    else
      user.update_attributes(facebook_share_count: user.facebook_share_count+1)
    end
    
    result['msg'] = Utilities::Message::MSG_OK
    return render json: result, status: :ok

  end

  def post_recommend
    result = Hash.new

    if !params[:user_id].present? || !params[:num].present? || !params[:lang].present? || !params[:url].present?
      Rails.logger.debug "share_most_annotated Post: Missing param"
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    public_key = params[:user_id]

    # Validate userID
    if !UserHandler.validate_public_key( public_key )
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] invalid param"
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    user = User.where(:public_key => public_key).first
    id = user.id
    if id.nil?
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    @user_ext_login = UserExternalLogin.find_with_user_id_and_provider(id, "facebook");
    if @user_ext_login.nil?
      Rails.logger.warn "share_most_annotated: User[" + public_key.to_s + "] has not registered a facebook account"
      result['msg'] = Utilities::Message::MSG_SOCIAL_LOGIN_ACCOUNT_NOT_REGISTERED
      return render json: result, status: :bad_request
    end

    @caption = "Using WordNews, I have learnt " + params[:num].to_s + " " + Utilities::Lang::CODE_TO_LANG[params[:lang].to_sym].downcase + " " + "word".pluralize(params[:num].to_i)
    @caption += " from this article." + params[:url].to_s

    host = request.protocol + request.host_with_port
    begin
      @graph = Koala::Facebook::API.new(@user_ext_login.oauth_token)
      @graph.put_wall_post(@caption, {:link => host} )
    rescue Exception => e
      Rails.logger.warn "Koala::Facebook: Error e.msg=>[" + e.message + "]"
      result['msg'] = "Error posting to Facebook"
      return render json: result, status: :bad_request
    end

    # give credits to user
    if user.facebook_share_count<MAX_FB_SHARE_WITH_CREDITS
      user.score += Utilities::UserLevel.get_score(:sns_share)
      user.rank += Utilities::UserLevel.upgrade_rank(user)
      user.update_attributes(facebook_share_count: user.facebook_share_count+1, 
                             score: user.score, rank: user.rank)
    else
      user.update_attributes(facebook_share_count: user.facebook_share_count+1)
    end


    result['msg'] = Utilities::Message::MSG_OK
    result['user'] = Hash.new
    result['user']['score'] = user.score
    result['user']['rank'] = user.rank
    return render json: result, status: :ok

  end

end