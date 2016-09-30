#!bin/env ruby
#encoding: utf-8
require 'json'
require 'set'

class LearningsController < ApplicationController

  def show_learn_words
    if !params[:lang].present? or !params[:translator].present? or 
      !params[:num_of_words].present? or !params[:user_id].present? or
      !params[:url_postfix].present? or !params[:url].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return
    end
      
    lang = params[:lang]
    translator = params[:translator]
    num_of_words = params[:num_of_words].to_i
    public_key = params[:user_id]
    url_postfix = params[:url_postfix]
    url = params[:url]
    website = params[:website]
    title = params[:title]
    publication_date = params[:publication_date]
    quiz_generator = params[:quiz_generator]? params[:quiz_generator].present? : 'lin_distance'
    
    user_id = User.where(:public_key => public_key).pluck(:id).first
    if user_id.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end

    # pre-process text
    @sentences = []
    @paragraphs = {} # idx: Paragraph
    
    params[:paragraphs].each do |idx, paragraph|
      if !paragraph[:text].nil? and !paragraph[:text].blank?
        p = Utilities::Paragraph.new(paragraph[:paragraph_index].strip(), paragraph[:text], translator, url)
        #puts p.index.to_s + ' ' + p.text
        s = p.process_text()
        if !s.nil? and s.any?
          @sentences += s
          @paragraphs[p.index] = p
        end
      end
    end

  
    article = Utilities::ArticleUtil.get_or_create_article(url, url_postfix, lang, website, title, publication_date)
    article_id = article['id']
    @words_to_learn = select_learn_words(num_of_words, user_id, lang, translator, article_id, quiz_generator, url)
    
    get_annotations(article_id, lang)
    puts '@words_to_learn size ' + @words_to_learn.size().to_s
    
    # response
    respond_to do |format|
      format.json { render json: { msg: Utilities::Message::MSG_OK, words_to_learn: @words_to_learn}, 
                    status: :ok }
    end
    
  end
  
  
  # 1. noun, verb, adj, adv only
  # 2. word is in the dictionary
  # 3. no duplicate words
  # 4. omit word in phrased annotations (TODO)
  # 5. consider word difficulty level and user's knowledge level (TODO)
  def select_learn_words(num_of_words, user_id, lang, translator, article_id, quiz_generator, url)
    @sentences.shuffle!
    words_to_learn = []
    word_set = Set.new
    
    i = 0
    @sentences.each do |sentence|
      if i>=num_of_words
        break
      end
      
      # one word per sentence
      select = false
      sentence.words.each_with_index do |word_text, index|
        if select
          break
        end
        
        word_pos = sentence.tags[index]
        if !word_text.nil? and !word_set.include?(word_text) and Utilities::Text.is_proper_to_learn(word_text, word_pos)
          word_id = Utilities::LearningUtil.get_word_id(word_text, Utilities::Lang::CODE[:English])

          if !word_id.nil?
            word_index = @paragraphs[sentence.paragraph_index].get_word_occurence_index(word_text, 
            sentence.sentence_index, index)
            word_sent_position = sentence.get_word_position(word_text, index)
            
            word = Utilities::Word.new(word_text, sentence.paragraph_index, sentence.sentence_index,
                                      word_index, word_id, word_pos, word_sent_position)
                                    
            # get translation result[id, translation]
            result = translate(word, sentence, lang, translator, article_id)
            if !result.nil?
              word.machine_translation_id = result[0]
              word.translation = result[1]
              word.weighted_vote = result[2]
              word.translation_id = Utilities::LearningUtil.get_word_id(word.translation, lang) 
            end

            if !word.translation.nil? and !word.translation_id.nil?
              word.pair_id = Utilities::LearningUtil.get_translation_pair_id(word.word_id, word.translation_id, lang)
              learn_test_type = Utilities::LearningUtil.get_learn_type(user_id, word.pair_id, lang) # view/test/skip
              word.learn_type = learn_test_type[0]
              word.test_type = learn_test_type[1]
              
              word.pronunciation = Utilities::LearningUtil.get_pronunciation_by_word_id(word.translation_id, lang)
              word.audio_urls = Utilities::LearningUtil.get_audio_urls(word.pronunciation, lang)
              word.more_url = Utilities::LearningUtil.get_more_url(word.translation, lang)
              
              if word.learn_type!='skip' and !word.pair_id.nil?
                if word.learn_type=='test'
                  article_category = Utilities::LearningUtil.get_article_category(url)
                  word.quiz = generate_quiz(quiz_generator, word.text, word.pos_tag, lang, word.test_type, article_category)
                end
                
                if !word.quiz.nil? or word.learn_type=='view'                 
                  words_to_learn.push(word)
                  puts word.text
                  puts word.translation
                  i += 1
                  word_set.add(word_text)
                  select = true
                end
              end
            end
          end
        end
      end
    end
    return words_to_learn
  end
  
  # Return at most ANNOTATION_COUNT_MAX top voted annotations
  # TODO: pronunciation provided by user?
  # TODO: change the order when vote weight rule changes
  def get_annotations(article_id, lang)
    @words_to_learn.each do |word|
      if word.learn_type=='view'
        word.annotations = Annotation.where('article_id=? AND paragraph_idx=? AND text_idx=? AND selected_text=?',
            article_id, word.paragraph_index, word.word_index, word.text).order('vote + ' + WEIGHT_IMPLICIT_VOTE.to_s + '*implicit_vote DESC').limit(ANNOTATION_COUNT_MAX).pluck_all(:id, :translation, :vote, :implicit_vote)
        if !word.annotations.nil?
          word.annotations.each do |annotation|
            annotation['pronunciation'] = Utilities::AnnotationUtil.get_pronunciation_by_word(annotation['translation'], lang)
            annotation['audio_urls'] = Utilities::LearningUtil.get_audio_urls(annotation['pronunciation'], lang)
            annotation['more_url'] = Utilities::LearningUtil.get_more_url(annotation['translation'], lang)
            annotation['weighted_vote'] = Utilities::LearningUtil.get_weighted_vote(annotation['vote'], annotation['implicit_vote'], 'human')
          end
        end
      end
    end
  end
  
  
  # First retrieve the translation from database. If not exits, request translator and save
  def translate(word, sentence, lang, translator, article_id)
    result = MachineTranslation.fetch_id_transl_votes_by_params1( article_id, word.paragraph_index, word.word_index, translator, lang, word.text)

    if !result.nil?
      return [result['id'], result['translation'], Utilities::LearningUtil.get_weighted_vote(result['vote'], result['implicit_vote'], 'machine')]
    end
      
    if translator == 'dict'
      translation = Utilities::LearningUtil.translate_by_dictionary(word.word_id, word.pos_tag, lang)
    elsif translator == 'ims'
      translation = Utilities::LearningUtil.translate_by_ims(word.text, word.position, sentence.text, lang)
    elsif translator == 'bing'
      translation = Utilities::LearningUtil.translate_by_bing(word.position, sentence.text, lang)
    end
    
    # save 
    if !translation.nil?
      mt = MachineTranslation.new(text:word.text, translation: translation,
        article_id:article_id, paragraph_idx: word.paragraph_index, text_idx: word.word_index, 
        translator: translator, lang:lang, vote: 0)
      mt.save
      return [mt.id, translation, 0]
    end
  end
  
  # TODO: use proper news_category 
  # TODO: continue this
  def generate_quiz(algorithm, word, word_pos, lang, test_type, article_category)
    if lang==Utilities::Lang::CODE[:Chinese]
      if algorithm=='lin_distance'
        return Utilities::LearningUtil.generate_quiz_chinese(word, word_pos, test_type, article_category)
      elsif algorithm=='recent'
        return Utilities::LearningUtil.generate_recent_quiz_chinese(user_id, test_type)
      end
    end
  end
  
  
  def view
    if !params[:user_id].present? or !params[:translation_pair_id].present? or !params[:lang]
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    user = User.where(:public_key => params[:user_id]).first
    if user.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    if !Utilities::UserLevel.validate(user.rank, :view)
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INSUFFICIENT_RANK}, 
                      status: :bad_request }
      end
      return 
    end
    
    learning_history = LearningHistory.where(
      user_id: user.id, 
      translation_pair_id: params[:translation_pair_id],   
      lang: params[:lang]).first
      
    success = true
    LearningHistory.transaction do
      if !learning_history.nil?
        success &&= learning_history.increment!(:view_count)
      else
        learning_history = LearningHistory.new(
          user_id: user.id, 
          translation_pair_id: params[:translation_pair_id],
          lang: params[:lang], 
          view_count:1,
          test_count:0)
          
        success &&= learning_history.save
        user.learning_count += 1
      end
      
      user.view_count += 1
      user.score += Utilities::UserLevel.get_score(:view)
      user.rank += Utilities::UserLevel.upgrade_rank(user)
      success &&= user.update_attributes(view_count: user.view_count, 
                                         score: user.score, 
                                         rank: user.rank,
                                         learning_count: user.learning_count)
    end
    
    respond_to do |format|
      if success
        format.json { render json: {msg: Utilities::Message::MSG_OK, 
                      user: {score: user.score, rank: user.rank}}, 
                      status: :ok }
      else
        format.json { render json: {msg: Utilities::Message::MSG_UPDATE_FAIL}, status: :ok }
      end
    end
   
  end
  
  # TODO: API params
  # TODO: If the user fails the test, decrease the test_count in his learning_history?
  def take_quiz
    if !params[:user_id].present? or !params[:translation_pair_id].present? or\
       !params[:answer].present? or !params[:lang].present?
       respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    user = User.where(:public_key => params[:user_id]).first
    if user.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    if !Utilities::UserLevel.validate(user.rank, :take_quiz)
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INSUFFICIENT_RANK}, 
                      status: :bad_request }
      end
      return 
    end
    
    learning_history = LearningHistory.where(
      user_id: user.id, 
      translation_pair_id: params[:translation_pair_id],
      lang: params[:lang]).first
      
    success = false
    if !learning_history.nil?
      success = true
      if params[:answer]=='correct'
        success &&= learning_history.increment!(:test_count)
        user.quiz_count += 1
        user.score += Utilities::UserLevel.get_score(:pass_quiz)
        user.rank += Utilities::UserLevel.upgrade_rank(user)
        if learning_history.test_count+1 == QUIZ_COUNT_MAX
          user.learning_count -= 1
          user.learnt_count += 1
        end
          
        success &&= user.update_attributes(view_count: user.view_count, 
                                           score: user.score, 
                                           rank: user.rank,
                                           learning_count: user.learning_count,
                                           learnt_count: user.learnt_count)
      end
      # TODO: need penalty for wrong answer?
      #elsif params[:answer]=='wrong' and learning_history.test_count>0
      #  success = learning_history.decrement!(:test_count)
      # end
    end
    
    respond_to do |format|
      if success
        format.json { render json: {msg: Utilities::Message::MSG_OK, 
                      user: {score: user.score, rank: user.rank}}, status: :ok }
      else
        format.json { render json: {msg: Utilities::Message::MSG_UPDATE_FAIL}, status: :ok }
      end
    end
  end
  
  
  # TODO: hide the correct answer on client side
  def take_quiz_hide
    if !params[:user_id].present? or !params[:translation_pair_id].present? or\
       !params[:correct_word_id].present? or !params[:choice_text].present? or\
       !params[:lang].present? or !params[:test_type].present?
       respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    user = User.where(:public_key => params[:user_id]).first
    if user.nil?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    if !Utilities::UserLevel.validate(user.rank, :view)
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INSUFFICIENT_RANK}, 
                      status: :bad_request }
      end
      return 
    end
    
    is_correct = LearningUtil.is_correct_answer(params[:correct_word_id], params[:choice_text], 
      params[:test_type].to_i, params[:translation_pair_id], params[:lang])
    
    learning_history = LearningHistory.where(
      user_id: user.id, 
      translation_pair_id: params[:translation_pair_id],
      lang: params[:lang]).first
      
    success = false
    if !learning_history.nil?
      success = true
      if is_correct
        success &&= learning_history.increment!(:test_count)
        user.quiz_count += 1
        user.score += Utilities::UserLevel.get_score(:pass_quiz)
        user.rank += Utilities::UserLevel.upgrade_rank(user)
        if learning_history.test_count+1 == QUIZ_COUNT_MAX
          user.learning_count -= 1
          user.learnt_count += 1
        end
          
        success &&= user.update_attributes(view_count: user.view_count, 
                                           score: user.score, 
                                           rank: user.rank,
                                           learning_count: user.learning_count,
                                           learnt_count: user.learnt_count)
      end
      # TODO: need penalty for wrong answer?
      #elsif params[:answer]=='wrong' and learning_history.test_count>0
      #  success = learning_history.decrement!(:test_count)
      # end
    end
    
    respond_to do |format|
      if success
        format.json { render json: {msg: Utilities::Message::MSG_OK, 
                      user: {score: user.score, rank: user.rank}}, status: :ok }
      else
        format.json { render json: {msg: Utilities::Message::MSG_UPDATE_FAIL}, status: :ok }
      end
    end
  end
  
  
  # statistics
  def show_user_learning_history
    if !params[:user_id].present? or !params[:lang].present? \
      or !UserHandler.validate_public_key(params[:user_id])
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
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
    
    #learning_count = LearningHistory.where('user_id=? AND lang=? AND test_count<?', user.id, params[:lang], VIEW_COUNT_MAX).count
    #learnt_count = LearningHistory.where('user_id=? AND lang=? and test_count=?',  user.id, params[:lang], QUIZ_COUNT_MAX).count
    
    respond_to do |format|
      format.json { render json: { msg: Utilities::Message::MSG_OK, 
                    history: {learning_count: user.learning_count, learnt_count: user.learnt_count }}, 
                    status: :ok }
    end
  end
  
  
  # words that user are learning or has learnt
  # TODO: audio URLs
  def show_user_words
    if (!params[:user_id].present? or !params[:lang].present? \
        or !UserHandler.validate_public_key(params[:user_id]) \
        or !params[:is_learning].present? or (params[:is_learning]!='0' and params[:is_learning]!='1'))
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end
    
    @user = UserHandler.get_user_by_public_key(params[:user_id])
    if @user.nil?
      # response
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return 
    end

    # TODO: better support other languages
    if params[:lang]==Utilities::Lang::CODE[:Chinese]
      if params[:is_learning]=='1' # words are learning
        @words = EnglishChineseTranslation.joins(:learning_histories).where('user_id=? AND lang=? AND test_count<?', 
        @user.id, params[:lang], VIEW_COUNT_MAX)
        @mode = 'are learning'
      elsif params[:is_learning]=='0' # words have learned (passed the max number of quiz)
        @words = EnglishChineseTranslation.joins(:learning_histories).where('user_id=? AND lang=? and test_count=?',  
        @user.id, params[:lang], QUIZ_COUNT_MAX)
        @mode = 'have learnt'
      end
    end
    
    @words.each do |word|
      word.audio_urls = Utilities::LearningUtil.get_audio_urls(word.chinese_pronunciation, params[:lang])
      word.more_url = Utilities::LearningUtil.get_more_url(word.chinese_text, params[:lang])
    end
    
    @target_lang = Utilities::Lang::CODE_TO_LANG[params[:lang].to_sym]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {msg: Utilities::Message::MSG_OK, words: @words, 
                                  lang: @target_lang, user_name: @user.user_name, mode: @mode}, 
                          status: :ok }
    end
    
  end
  
end
