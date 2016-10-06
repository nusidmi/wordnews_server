class ArticlesController < ApplicationController
  require 'date'
  
  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.json
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(params[:article])

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.json
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :no_content }
    end
  end
  
  
  # from_date and to_date are optional (both provided or both omitted)
  # TODO: html shows error msg properly
  def show_most_annotated_urls
    if !params[:lang].present?  or !params[:num].present?  \
        or !ValidationHandler.validate_integer(params[:num]) \
        or params[:from_date].present?^params[:to_date].present?
        
      respond_to do |format|
        format.html { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
    return
    end

    @from_date = nil
    @to_date = nil
    @user_id = nil
    if params[:from_date].present? and params[:to_date].present? 
      @from_date = params[:from_date]
      @to_date = params[:to_date]
    
      if !ValidationHandler.validate_date(@from_date) or !ValidationHandler.validate_date(@to_date)
        respond_to do |format|
          format.html { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
          format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
        end
        return
      end
      
      @articles = Article.where(lang: params[:lang], publication_date: 
                                @from_date..@to_date).order('annotation_count desc').limit(params[:num])
      @time_msg = 'from ' + @from_date + ' to ' + @to_date
    else
      @articles = Article.where(lang: params[:lang]).order('annotation_count desc').limit(params[:num])
      @time_msg = 'all the time'
    end
    
    @articles.each do |article|
      article.lang = Utilities::Lang::CODE_TO_LANG[article.lang.to_sym]
    end

    if params[:user_id].present?
      @user_id = params[:user_id]
    end

    respond_to do |format|
      format.html # show_most_annotated_urls.html.erb
      format.json { render json: {msg: Utilities::Message::MSG_OK, urls: @articles}, 
                  status: :ok}
    end
  end
  
end
