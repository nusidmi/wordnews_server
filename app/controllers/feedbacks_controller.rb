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
      @translation = MachineTranslation.fetch_trans_by_id(params[:translation_pair_id])
    elsif params[:source]=='1'
      @translation = Annotation.find_by_id(params[:translation_pair_id])
    else
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end

    user = User.where(:public_key => params[:user_id]).first
    score = params[:score].to_i

    if user.nil? or @translation.nil?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :bad_request}
      end
      return
    end
    
    is_explicit = (params[:is_explicit].to_i==1)? true: false
    vote_history = VoteHistory.where(user_id: user.id, pair_id: params[:translation_pair_id],
            source: TRANSLATION_SOURCE[params[:source]], is_explicit: is_explicit).first
    
    success = true
    VoteHistory.transaction do
      if vote_history.nil?
        vote_history = VoteHistory.new(pair_id: @translation.id, user_id: user.id, 
          vote: score, source: TRANSLATION_SOURCE[params[:source]], is_explicit: is_explicit)
        success &&= vote_history.save
        if is_explicit
          success &&= @translation.update_attribute(:vote, @translation.vote+score)
          user.vote_count += 1
          user.score += Utilities::UserLevel.get_score(:explict_vote)
          user.rank += Utilities::UserLevel.upgrade_rank(user)
          success &&= user.update_attributes(vote_count: user.vote_count, score: user.score, rank: user.rank)
        else
          success &&= @translation.increment!(:implicit_vote)
          user.score += Utilities::UserLevel.get_score(:implicit_vote)
          user.rank += Utilities::UserLevel.upgrade_rank(user)
          success &&= user.update_attributes(score: user.score, rank: user.rank)
        end
      # The user has voted the translation before, but changed the score.
      elsif is_explicit and vote_history.vote!=score
        success &&= @translation.update_attribute(:vote, @translation.vote+score-@vote_history.vote)
        success &&= vote_history.update_attribute(:vote, score)
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
