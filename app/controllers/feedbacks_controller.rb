class FeedbacksController < ApplicationController

  # vote machine translation and human annotation
  def vote
    if !params[:translation_pair_id].present? or !params[:user_id].present? or 
      !params[:score] or !ValidationHandler.validate_integer(params[:score]) or
      !params[:source]
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end
    
    if params[:source]=='machine'
      @translation = MachineTranslation.find_by_id(params[:translation_pair_id])
    elsif params[:source]=='human'
      @translation = Annotation.find_by_id(params[:translation_pair_id])
    end

    @user = User.where(:public_key => params[:user_id]).first
    @vote_history = VoteHistory.where(user_id: @user.id, pair_id: params[:translation_pair_id],
            source: TRANSLATION_SOURCE[params[:source]]).first
    score = params[:score].to_i

    if @user.nil? or @translation.nil?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :bad_request}
      end
      return
    end
    
    success = true
    VoteHistory.transaction do
      if @vote_history.nil?
        @vote_history = VoteHistory.new(pair_id: @translation.id, user_id: @user.id, 
              vote: score, source: TRANSLATION_SOURCE[params[:source]])
        success &&= @vote_history.save 
        success &&= @translation.update_attribute(:vote, @translation.vote+score)
      elsif @vote_history.vote!=score
          success &&= @translation.update_attribute(:vote, @translation.vote+score-@vote_history.vote)
          success &&= @vote_history.update_attribute(:vote, score)
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
