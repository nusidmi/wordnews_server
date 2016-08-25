#!bin/env ruby
#encoding: utf-8
require 'json'
require 'set'

class LearningsController < ApplicationController

  # Params: lang, text in the paragraph, and paragraph index
  # Return: {[word, translation, paragraph_index, word_index]
  def show_learn_words
    if !params[:lang].present? or !params[:translator].present? or 
      !params[:num_of_words].present? or !params[:user_id].present? or
      !params[:url_postfix].present?
      respond_to do |format|
        format.json { render json: { msg: Utilities::Message::MSG_INVALID_PARA}, 
                      status: :bad_request }
      end
      return
    end
      
    lang = params[:lang]
    translator = params[:translator]
    num_of_words = params[:num_of_words].to_i
    user_id = params[:user_id]
    url_postfix = params[:url_postfix]
    url = params[:url]
    website = params[:website]
    title = params[:title]
    publication_date = params[:publication_date]

    # pre-process text
    @sentences = []
    @paragraphs = {} # idx: Paragraph
    
    params[:paragraphs].each do |idx, paragraph|
      if !paragraph[:text].nil? and !paragraph[:text].blank?
        p = Utilities::Paragraph.new(paragraph[:paragraph_index], paragraph[:text])
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
    @words_to_learn = select_learn_words(num_of_words, user_id, lang, translator, article_id)
    
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
  def select_learn_words(num_of_words, user_id, lang, translator, article_id)
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
          word_id = get_word_id(word_text, Utilities::Lang::CODE[:English])

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
              word.translation_id = get_word_id(word.translation, lang) 
            end

            if !word.translation.nil? and !word.translation_id.nil?
              word.pair_id = get_translation_pair_id(word.word_id, word.translation_id, lang)
              word.learn_type = get_learn_type(user_id, word.pair_id, lang) # view/test/skip
              word.pronunciation = get_pronunciation_by_word_id(word.translation_id, lang)
              
              if word.learn_type!='skip' and !word.pair_id.nil?
                if word.learn_type=='test'
                  word.quiz = generate_quiz(word.text, lang)
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
  def get_annotations(article_id, lang)
    @words_to_learn.each do |word|
      if word.learn_type=='view'
        word.annotations = Annotation.where('article_id=? AND paragraph_idx=? AND text_idx=? AND selected_text=?',
            article_id, word.paragraph_index, word.word_index, word.text).order('vote desc').limit(ANNOTATION_COUNT_MAX).pluck_all(:id, :translation)
        if !word.annotations.nil?
          word.annotations.each do |annotation|
            annotation['pronunciation'] = get_pronunciation_by_word(annotation['translation'], lang)
          end
        end
      end
    end
  end
  
  
  # First retrieve the translation from database. If not exits, request translator and save
  def translate(word, sentence, lang, translator, article_id)
    result = MachineTranslation.where(article_id: article_id, paragraph_idx: word.paragraph_index,
          text_idx: word.word_index, translator: translator, lang: lang, text:word.text).pluck_all(:id, :translation).first
    
    if !result.nil?
      return [result['id'], result['translation']]
    end
      
    if translator == 'dict'
      translation = translate_by_dictionary(word.word_id, word.pos_tag, lang)
    elsif translator == 'ims'
      translation translate_by_ims(word.text, sentence.text, lang)
    elsif translator == 'bing'
      translation = translate_by_bing(word.position, sentence.text, lang)
    end
    
    # save 
    if !translation.nil?
      mt = MachineTranslation.new(text:word.text, translation: translation,
        article_id:article_id, paragraph_idx: word.paragraph_index, text_idx: word.word_index, 
        translator: translator, lang:lang, vote: 0)
      mt.save
      return [mt.id, translation]
    end
  end
  
  
  # English -> Chinese
  def translate_by_dictionary(word_id, word_pos, lang)
    if lang==Utilities::Lang::CODE[:Chinese] and POS_INDEX.has_key?(word_pos)
      translation_id = EnglishChineseTranslation.where('english_vocabulary_id=? AND pos_tag=? AND frequency_rank=0', word_id, POS_INDEX[word_pos]).pluck(:chinese_vocabulary_id)
      if !translation_id.nil?
        translation = ChineseVocabulary.where(id: translation_id).pluck(:text).first
        return translation
      end
    end
  end
  
  
  # English -> Chinese
  # word_position is [start_character_index, end_character_index] for the word in sentence
  def translate_by_bing(word_position, sentence, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      translation = Bing.translate_word(word_position, sentence, 'en', 'zh-CHS')
      return translation
    end
  end
  
  # TODO
  def translate_by_ims(word_text, sentence, lang)
    
  end

  # TODO: design the rule
  # view/test/skip the word based on user's learning history
  def get_learn_type(user_id, pair_id, lang)
    learning_history = LearningHistory.where(user_id: user_id, translation_pair_id: pair_id, lang: lang).first
    if learning_history.nil?
      history = LearningHistory.new(user_id: user_id, translation_pair_id: pair_id, 
                                      lang: lang, view_count: 0, test_count: 0)
      history.save
      return 'view'
    elsif learning_history.test_count>=QUIZ_FREQUENCY_COUNT_MAX  # user knows this word well
      return 'skip'
    elsif learning_history.test_count==0 and learning_history.view_count<VIEW_COUNT_MAX
      return 'view'
    else
      return 'test'
    end
  end
  
  
  # Return nil if the word is not stored in database
  def get_word_id(word, lang)
    if !word.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return ChineseVocabulary.where(text: word).pluck(:id).first
      elsif lang==Utilities::Lang::CODE[:English]
        return EnglishVocabulary.where(text: word).pluck(:id).first
      end
    end
  end
  
  
  def get_translation_pair_id(source_word_id, target_word_id, target_lang)
    if target_lang==Utilities::Lang::CODE[:Chinese]
      return EnglishChineseTranslation.where(english_vocabulary_id: source_word_id, chinese_vocabulary_id: target_word_id).pluck(:id).first
    end
  end
  
  
  def get_pronunciation_by_word_id(word_id, lang)
    if !word_id.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return ChineseVocabulary.where(id: word_id).pluck(:pronunciation).first
      end
    end
  end
  
  
  def get_pronunciation_by_word(word, lang)
    if !word.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return ChineseVocabulary.where(text: word).pluck(:pronunciation).first
      end
    end
  end
  
    
  
  def generate_quiz(word, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      return generate_quiz_chinese(word.text)
    else
      return nil
    end
  end
  
  
  # TODO: remove category
  def generate_quiz_chinese(word_text)
    category = 'Technology'
    level = 3
      
    begin
      distractors_str = `python "public/MCQ Generation/MCQGenerator.py" #{category} #{level} #{word_text}`
      distractors = distractors_str.split(',')
      quiz = Hash.new
      
      quiz= Hash.new
      quiz['testType'] = 
      quiz['choices'] = Hash.new
  
      distractors.each_with_index { |val, idx|
        quiz['choices'][idx.to_s] = val.strip
      }
      return quiz
    rescue Exception => e
      Rails.logger.warn "MCQGenerator.py: Error e.msg=>[" + e.message + "]"
    end
    
  end
  
end
