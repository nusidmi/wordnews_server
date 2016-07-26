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
    if params[:user_id].present? and params[:url].present?
      @annotations = Annotation.where('user_id=? AND url=?', params[:user_id], params[:url])
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_OK, annotations: @annotations}, 
                      status: :ok}
      end
    else
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
    end
  end
  
  def show_by_url
    if params[:url].present?
      @annotations = Annotation.where('url=?', params[:url])
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_OK, annotations: @annotations}, 
                      status: :ok}
      end
    else
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
    end
  end
  
  def show_count_by_url
    if params[:url].present?
      count = Annotation.count('id', :conditions=>['url=?', params[:url]])
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_OK, 
                      annotation_count: count},
                      status: :ok}
      end
    else
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
    end
  end
  
  
  # TODO: Move to users_controller.rb?
  def show_user_annotation_history
    if params[:user_id].present?
      sql = 'user_id=' + params[:user_id]
      total_annotation = Annotation.count('id', :conditions=>sql)
      total_url = Annotation.count('url', :conditions=>sql, distinct: true)
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_OK, 
                      history: {annotation: total_annotation, url: total_url}},
                      status: :ok}
      end
    else
      respond_to do |format|
        format.json { render json: {msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request}
      end
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
    if (params[:annotation].present? and params[:annotation][:ann_id].present? \
        and params[:annotation][:user_id].present? \
        and params[:annotation][:selected_text].present? \
        and params[:annotation][:translation].present? \
        and params[:annotation][:lang].present?\
        and params[:annotation][:url].present? \
        and params[:annotation][:paragraph_idx].present?\
        and params[:annotation][:text_idx].present?) 
      @annotation = Annotation.new(params[:annotation])
      
      respond_to do |format|
        if @annotation.save
          format.html { redirect_to @annotation, notice: 'Annotation was successfully created.' }
          format.json { render json: {msg: Utilities::Message::MSG_OK, id: @annotation.id},
                        status: :ok }
        else
          format.html { render action: "new" }
          format.json { render json: @annotation.errors, status: :bad_request }
        end
      end
    else
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA }, 
                      status: :bad_request } 
      end
    end
  end

  # PUT /annotations/1
  # PUT /annotations/1.json
  def update
    @annotation = Annotation.find(params[:id])

    respond_to do |format|
      if @annotation.update_attributes(params[:annotation])
        format.html { redirect_to @annotation, notice: 'Annotation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @annotation.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update_translation
    if !params[:id].present? or !params[:translation].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA }, 
                      status: :bad_request } 
      end
      return
    end
    
    @annotation = Annotation.find_by_id(params[:id])
    if @annotation
      if @annotation.update_attribute(:translation, params[:translation])
        respond_to do |format|
          format.json { render json:{ msg: Utilities::Message::MSG_OK}, 
                        status: :ok}
        end
      else
        respond_to do |format|
          format.json { render json:{ msg: Utilities::Message::MSG_UPDATE_FAIL}, 
                        status: :ok} 
        end
      end
    else
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :ok }
      end
    end
  end
    
    

  # DELETE /annotations/1
  # DELETE /annotations/1.json
  def destroy
    if !params[:id].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                        status: :bad_request }
      end
      return
    end
      
    @annotation = Annotation.find_by_id(params[:id])
    if @annotation
      @annotation.destroy
  
      respond_to do |format|
        format.html { redirect_to annotations_url }
        format.json { render json: { msg: Utilities::Message::MSG_OK },
                      status: :ok}
      end
    else
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_NOT_FOUND}, 
                      status: :ok }
      end
    end
  end
  

  #private
    #def validate_annotation
      #params.require[:annotation].permits(:)
    #end
  
end






