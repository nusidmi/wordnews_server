class FeedbacksController < ApplicationController

  # vote machine translation and human annotation
  def vote
    if !params[:translation_pair_id].present? or !params[:user_id].present? or 
      !params[:score].present? or !ValidationHandler.validate_integer(params[:score]) or
      !params[:source].present? or !params[:is_explicit].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end
    
    if params[:source]=='0'
      @translation = MachineTranslation.find_by_id(params[:translation_pair_id])
    elsif params[:source]=='1'
      @translation = Annotation.find_by_id(params[:translation_pair_id])
    else
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end

    @user = User.where(:public_key => params[:user_id]).first
    score = params[:score].to_i

    if @user.nil? or @translation.nil?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :bad_request}
      end
      return
    end
    
    success = true
    
    # explicit rating 
    if params[:is_explicit]=='1'
      VoteHistory.transaction do
        vote_history = VoteHistory.where(user_id: @user.id, pair_id: params[:translation_pair_id],
            source: TRANSLATION_SOURCE[params[:source]], is_explicit: true).first
        if vote_history.nil?
          vote_history = VoteHistory.new(pair_id: @translation.id, user_id: @user.id, 
                vote: score, source: TRANSLATION_SOURCE[params[:source]], is_explicit: true)
          success &&= vote_history.save 
          success &&= @translation.update_attribute(:vote, @translation.vote+score)
        elsif vote_history.vote!=score
            success &&= @translation.update_attribute(:vote, @translation.vote+score-@vote_history.vote)
            success &&= vote_history.update_attribute(:vote, score)
        end
      end
    # implicit rating
    elsif params[:is_explicit]=='0'
      VoteHistory.transaction do
        vote_history = VoteHistory.where(user_id: @user.id, pair_id: params[:translation_pair_id],
            source: TRANSLATION_SOURCE[params[:source]], is_explicit: false).first
        # not a duplicate clicking 
        if vote_history.nil?
          vote_history = VoteHistory.new(pair_id: @translation.id, user_id: @user.id, 
                vote: score, source: TRANSLATION_SOURCE[params[:source]], is_explicit: false)
          success &&= vote_history.save
          success &&= @translation.increment!(:implicit_vote)
        end
      end
    end
    
    respond_to do |format|
      if success
        format.json { render json: { msg: Utilities::Message::MSG_OK },
                      status: :ok}
      else
        format.json { render json: { msg: Utilities::Message::MSG_VOTE_FAIL },
                      status: :ok}
      end
    end
  end
  
end
