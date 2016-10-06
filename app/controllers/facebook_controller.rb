
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

    id = User.where(:public_key => public_key).pluck(:id).first
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

    @link = ENV['HOST_ADDRESS'] + "/show_most_annotated_urls?" + query_str

    @graph = Koala::Facebook::API.new(@user_ext_login.oauth_token)
    @graph.put_wall_post("Go checkout annotated these articles!", {:name => "Most annotated articles", :link => @link })


    result['msg'] = Utilities::Message::MSG_OK
    return render json: result

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

    id = User.where(:public_key => public_key).pluck(:id).first
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

    @graph = Koala::Facebook::API.new(@user_ext_login.oauth_token)
    @graph.put_wall_post(@caption, {:link => ENV['HOST_ADDRESS'].to_s} )


    result['msg'] = Utilities::Message::MSG_OK
    return render json: result

  end

end