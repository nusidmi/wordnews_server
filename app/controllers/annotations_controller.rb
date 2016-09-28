#require 'message_code.rb'

class AnnotationsController < ApplicationController
  
  # GET /annotations
  # GET /annotations.json
  def index
    @annotations = Annotation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @annotations }
    end
  end

  # GET /annotations/1
  # GET /annotations/1.json
  def show
    @annotation = Annotation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @annotation }
    end
  end
  
  
  def show_by_user_url
    if !params[:user_id].present? or !params[:url_postfix].present? or !params[:lang].present?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end

    user = User.where(:public_key => params[:user_id]).first
    if user.nil?
      # response
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    user_id = user.id

    article_id = Utilities::ArticleUtil.get_article_id(params[:url_postfix], params[:lang])
    
    @annotations = article_id.nil? ? {}: Annotation.joins(:annotation_histories).where('annotation_histories.user_id=? AND article_id=?', user_id, article_id)
     
    respond_to do |format|
      format.json { render json: {msg: Utilities::Message::MSG_OK, annotations: @annotations}, 
                    status: :ok}
    end
  end
  
  
  def show_by_url
    if !params[:url_postfix].present? or !params[:lang].present?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end
    
    article_id = Utilities::ArticleUtil.get_article_id(params[:url_postfix], params[:lang])
    @annotations = article_id.nil? ? {} : Annotation.where('article_id=?', article_id)
    
    respond_to do |format|
      format.json { render json: {msg: Utilities::Message::MSG_OK, annotations: @annotations}, 
                    status: :ok}
    end
  end
  
  
  def show_count_by_url
    if !params[:url_postfix].present? or !params[:lang].present?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end
    
    count = Article.where('url_postfix=? AND lang=?', params[:url_postfix], params[:lang]).pluck(:annotation_count).first
    
    respond_to do |format|
      format.json { render json: {msg: Utilities::Message::MSG_OK, 
                    annotation_count: count}, status: :ok}      
    end
  end
  
  
  # TODO: 1. Move to users_controller.rb? 2. Add two columns in user table
  # lang is optional
  def show_user_annotation_history
    
    if !params[:user_id].present?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end

    user = User.where(:public_key => params[:user_id]).first
    if user.nil?
      # response
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    user_id = user.id

    if params[:lang].present?
      total_annotation = AnnotationHistory.where(user_id: user_id, lang: params[:lang]).count('id')
      total_url = AnnotationHistory.where(user_id: user_id, lang: params[:lang]).joins(:annotation).count('article_id', distinct: true)
    else
      total_annotation = AnnotationHistory.where(user_id: user_id).count('id')
      total_url = AnnotationHistory.where(user_id: user_id).joins(:annotation).count('article_id', distinct: true)
    end
    
    respond_to do |format|
      format.json { render json: {msg: Utilities::Message::MSG_OK, 
                    history: {annotation: total_annotation, url: total_url}},
                    status: :ok}
    end
   
  end
  
  # All the annotations done by a user
  # lang is optional
  def show_user_annotations    
    if !params[:user_id].present?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end

    # invalid ID
    @user = User.where(:public_key => params[:user_id]).first
    if @user.nil?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end
      
    if params[:lang].present?
      @annotations = Annotation.where('annotations.lang=?', params[:lang]).joins(:annotation_histories).where('user_id=?', @user.id)
    else
      @annotations = Annotation.joins(:annotation_histories).where('user_id=?', @user.id)
    end
    respond_to do |format|
      format.html # show_user_annotations.html.erb
      format.json { render json: {msg: Utilities::Message::MSG_OK, annotations: @annotations}, 
                    status: :ok}
    end
  end
  
  
  # All the annotated urls done by a user
  # lang is optional
  def show_user_urls
    if !params[:user_id].present?
       respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end

    @user = User.where(:public_key => params[:user_id]).first
    if @user.nil?
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
      return
    end
    
    if params[:lang].present?
      article_ids = Annotation.joins(:annotation_histories).where('user_id=? and lang=?', @user.id, params[:lang]).pluck(:article_id).uniq
    else
      article_ids = Annotation.joins(:annotation_histories).where('user_id=?', @user.id).pluck(:article_id).uniq
    end
    
    @articles = Article.where(id: article_ids)

    respond_to do |format|
      format.html # show_user_annotations.html.erb
      format.json { render json: {msg: Utilities::Message::MSG_OK, articles: @articles}, status: :ok}
    end
  end
  


  # GET /annotations/new
  # GET /annotations/new.json
  def new
    @annotation = Annotation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @annotation }
    end
  end

  # GET /annotations/1/edit
  def edit
    @annotation = Annotation.find(params[:id])
  end


  # POST /annotations
  # POST /annotations.json
  def create
    
    # TODO: a better validation strategy (use strong parameter?)
    if (!params[:annotation].present? or !params[:annotation][:ann_id].present? \
        or !params[:annotation][:user_id].present? \
        or !params[:annotation][:selected_text].present? \
        or !params[:annotation][:translation].present? \
        or !params[:annotation][:lang].present?\
        or !params[:annotation][:paragraph_idx].present?\
        or !params[:annotation][:text_idx].present?\
        or !params[:annotation][:url].present? \
        or !params[:annotation][:url_postfix].present? \
        or !params[:annotation][:website].present?)
        
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA }, 
                      status: :bad_request } 
      end
      return
    end

    user = User.where(:public_key => params[:annotation][:user_id]).first
    
    if !Utilities::UserLevel.validate(user.rank, :annotate_news_sites)
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INSUFFICIENT_RANK}, 
                      status: :bad_request }
      end
      return 
    end

    # Obtain article or create if not exists
    article = Utilities::ArticleUtil.get_or_create_article(
      params[:annotation][:url], params[:annotation][:url_postfix],
      params[:annotation][:lang], params[:annotation][:website], 
      params[:annotation][:title], params[:annotation][:publication_date])
      
    @annotation = Annotation.where(
      selected_text: params[:annotation][:selected_text],
      translation: params[:annotation][:translation],
      lang: params[:annotation][:lang],
      paragraph_idx: params[:annotation][:paragraph_idx],
      text_idx: params[:annotation][:text_idx],
      article_id: article.id).first
      
    # TODO: consider to increase upvote when annotation exists
    if @annotaion.nil?
      @annotation = Annotation.new(
      selected_text: params[:annotation][:selected_text],
      translation: params[:annotation][:translation],
      lang: params[:annotation][:lang],
      paragraph_idx: params[:annotation][:paragraph_idx],
      text_idx: params[:annotation][:text_idx],
      article_id: article.id)
    end
    
    @annotation_history = AnnotationHistory.new(
      client_ann_id: params[:annotation][:ann_id], 
      user_id: user.id,
      lang: params[:annotation][:lang])
    
    success = true
    Annotation.transaction do
      success &&= @annotation.save
      success &&= article.increment!(:annotation_count)
      @annotation_history.annotation_id = @annotation.id
      success &&= @annotation_history.save
      
      user.annotation_count += 1
      user.score += Utilities::UserLevel.get_score(:create_annotation)
      user.rank += Utilities::UserLevel.upgrade_rank(user)
      success &&= user.update_attributes(annotation_count: user.annotation_count,
                                         score: user.score,
                                         rank: user.rank)
    end
    
    respond_to do |format|
      if success
        format.json { render json: {
                        msg: Utilities::Message::MSG_OK, 
                        id: @annotation.id,
                        user: {score: user.score, rank: user.rank}}, 
                      status: :ok }
      else
        format.json { render json: @annotation.errors, status: :bad_request }
      end
    end
  end


  def update_translation
    if !params[:id].present? or !params[:translation].present? or !params[:user_id].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA }, 
                      status: :bad_request } 
      end
      return
    end

    @user = User.where(:public_key => params[:user_id]).first

    @annotation = Annotation.find_by_id(params[:id])
    @user_history = AnnotationHistory.where(annotation_id: params[:id], user_id: @user.id).first

    if @annotation.nil? or @user_history.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :ok }
      end
      return
    end
    
    @new_annotation = Annotation.new(
      selected_text: @annotation.selected_text,
      translation: params[:translation],
      lang: @annotation.lang,
      paragraph_idx: @annotation.paragraph_idx,
      text_idx: @annotation.text_idx,
      article_id: @annotation.article_id)
  
    # delete previous annotation if no other users link to
    user_count = AnnotationHistory.where(annotation_id: params[:id]).count

    Annotation.transaction do
      if (user_count>1 or @annotation.destroy) and @new_annotation.save and @user_history.update_attribute('annotation_id', @new_annotation.id)
        respond_to do |format|
          format.json { render json:{ msg: Utilities::Message::MSG_OK, id: @new_annotation.id}, 
                        status: :ok}
        end
        return
      end
    end
    
    respond_to do |format|
      format.json { render json:{ msg: Utilities::Message::MSG_UPDATE_FAIL}, 
                        status: :ok} 
    end
        
  end
    

  def destroy
    if !params[:id].present? or !params[:user_id].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end

    user = User.where(:public_key => params[:user_id]).first
    annotation = Annotation.find_by_id(params[:id])
    user_history = AnnotationHistory.where(annotation_id: params[:id], user_id: user.id).first

    if annotation.nil? or user_history.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :ok }
      end
      return
    end
    
    article = Article.find_by_id(annotation.article_id)
    if article.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :ok }
      end
      return
    end
    
    user_count = AnnotationHistory.where(annotation_id: params[:id]).count

    success = true
    Annotation.transaction do
      if user_count==1  # only one user contributes to the annotation
        annotation.destroy
        success &&= annotation.destroyed?
      end
      
      user_history.destroy
      success &&= user_history.destroyed?
      success &&= article.decrement!(:annotation_count)
      
      user.annotation_count -= 1
      user.score += Utilities::UserLevel.get_score(:delete_annotation)
      user.rank += Utilities::UserLevel.upgrade_rank(user)
      success &&= user.update_attributes(annotation_count: user.annotation_count,
                                         score: user.score,
                                         rank: user.rank)
    end
    
    respond_to do |format|
      if success
        format.json { render json: { msg: Utilities::Message::MSG_OK}, 
                      status: :ok }
      else
        format.json { render json: { msg: Utilities::Message::MSG_DELETE_FAIL},
                      status: :ok}
      end
    end
  end
  
  #private
    #def validate_annotation
    #  params.require[:annotation].permits(:)
    #end
  #end
  
  
end






