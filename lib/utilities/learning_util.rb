require 'httparty'

module Utilities::LearningUtil
  
  # Return nil if the word is not stored in database
  def self.get_word_id(word, lang)
    if !word.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return Utilities::ChineseVocabularyHandler.get_id_by_word( word )
      elsif lang==Utilities::Lang::CODE[:English]
        return Utilities::EnglishVocabularyHandler.get_id_by_word( word )
      end
    end
  end
  
  
  def self.get_translation_pair_id(source_word_id, target_word_id, target_lang)
    if target_lang==Utilities::Lang::CODE[:Chinese]
      return Utilities::EnglishChineseTranslationHandler.get_trans_id_by_eng_id_and_ch_id( source_word_id, target_word_id )
    end
  end
  
  
  def self.get_target_word_by_translation_pair_id(pair_id, target_lang)
    if target_lang==Utilities::Lang::CODE[:Chinese]
       return Utilities::EnglishChineseTranslationHandler.get_ch_word_by_trans_id(pair_id)
    end
  end
  
  def self.get_audio_urls(pronunciation, lang)
    if !pronunciation.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        urls = []
        pronunciation.split.each do |pinyin|
          urls.push(CHINESE_AUDIO_HOST + '/' + pinyin + '.mp3')
        end
        return urls
      end
    end
  end
  
  def self.get_more_url(word, lang)
    if !word.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return CHINESE_MORE_HOST + '/' + word
      end
    end
  end
  
  
  def self.get_pronunciation_by_word_id(word_id, lang)
    if !word_id.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return Utilities::ChineseVocabularyHandler.get_pronunciation_by_id( word_id )
      end
    end
  end
  
  
  def self.get_pronunciation_by_word(word, lang)
    if !word.nil?
      if lang==Utilities::Lang::CODE[:Chinese]
        return Utilities::ChineseVocabularyHandler.get_pronunciation_by_word(word)
      end
    end
  end
  
  
  # TODO: design the rule
  # view/test/skip the word based on user's learning history
  # TODO: return test_type 
  def self.get_learn_type(user_id, pair_id, lang)
    learning_history = LearningHistory.where(user_id: user_id, translation_pair_id: pair_id, lang: lang).first
    if learning_history.nil?
      return ['view', 0]
    elsif learning_history.test_count>=QUIZ_FREQUENCY_COUNT_MAX  # user knows this word well
      return ['skip', 0]
    elsif learning_history.test_count==0 and learning_history.view_count<VIEW_COUNT_MAX
      return ['view', 0]
    elsif learning_history.test_count<=QUIZ_FREQUENCY_COUNT_MAX/2
      return ['test', 1] # English distractors
    else
      return ['test', 2] # Chinese distractors
    end
  end
  
  
   # English -> Chinese
  def self.translate_by_dictionary(word_id, word_pos, lang)
    if lang==Utilities::Lang::CODE[:Chinese] and POS_INDEX.has_key?(word_pos)
      translation_id = Utilities::EnglishChineseTranslationHandler.get_cn_id_by_en_id_and_postag( word_id, POS_INDEX[word_pos])
      if !translation_id.nil?
        translation = Utilities::ChineseVocabularyHandler.get_ch_text_by_id(translation_id)
        return translation
      end
    end
  end
  
  
  # English -> Chinese
  # word_position is [start_character_index, end_character_index] for the word in sentence
  def self.translate_by_bing(word_position, sentence, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      translation = Utilities::Bing.translate_word(word_position, sentence, 'en', 'zh-CHS')
      return translation
    end
  end
  
  
  def self.translate_by_ims(word, word_position, sentence, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      return Utilities::ImsTranslator.translate(word, word_position, sentence)
    end    
  end


  # TODO: Change this if a new rule is designed
  def self.get_weighted_vote(explicit_vote, implicit_vote, translate_type)
    vote = explicit_vote + WEIGHT_IMPLICIT_VOTE * implicit_vote
    weight = (translate_type=='machine')? 1:WEIGHT_HUMAN_ANNOTATION
    return vote*weight
  end
  
  
   # TODO: remove category
  def self.generate_quiz_chinese_script(word_text)
    category = 'Technology'
    level = 3
      
    begin
      distractors_str = `python "public/MCQ Generation/MCQGenerator.py" #{category} #{level} #{word_text}`
      distractors = distractors_str.split(',')
      quiz = Hash.new
      
      quiz= Hash.new
      quiz['test_type'] = 1   # 0: no type, 1: choice in english, 2: choice in chinese
      quiz['choices'] = Hash.new
  
      distractors.each_with_index { |val, idx|
        quiz['choices'][idx.to_s] = val.strip
      }
      return quiz
    rescue Exception => e
      Rails.logger.warn "MCQGenerator.py: Error e.msg=>[" + e.message + "]"
    end
  end
  
  # knowledge_level: 1(random English alogrithm), 2(English distractors by hard algorithm), 3 (Chinese distractors by hard algorithm)
  # news_category: Entertainment, World, Finance, Sports, Technology, Travel, or Any
  def self.generate_quiz_chinese(word, word_pos, test_type, news_category='Any')
    params = {'word': word, 'word_pos': word_pos, 'test_type': test_type,
              'news_category':news_category}
    response = HTTParty.post(QUIZ_HOST+'/generate_quiz', 
                        :body=>params.to_json, 
  	                    :headers => {'Content-Type' => 'application/json'})
  	                    
    if response.code!=200 or response.body=='' or response.body=='Invalid Parameters'
      Rails.logger.warn "MCQ Generator: Error"
      return []
    end
    
    results = JSON.parse(response.body)
    
    quiz= Hash.new
    quiz['test_type'] = test_type  # 0: no type, 1: choice in english, 2: choice in chinese
    quiz['choices'] = Hash.new
    results.each_with_index do |result, idx|
      quiz['choices'][idx.to_s] = result
    end
    
    return quiz
  end
  
  # Use the most recent learned three words as the distractors
  def self.generate_recent_quiz_chinese(user_id, test_type)
    pair_ids = LearningHistory.where(user_id: user_id).order('updated_at desc').limit(3)
    if test_type==2
      distractors = EnglishChineseTranslation.where(id: pair_ids).pluck(:chinese_text)
    else
      distractors = EnglishChineseTranslation.where(id: pair_ids).pluck(:english_text)
    end
    return distractors
  end
  
  
  
  def self.get_correct_answer(correct_word_id, choice_text, test_type, pair_id, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      if test_type==1 # English distractor
        return correct_word_id==self.get_id_by_word(choice_text, lang)
      elsif test_type==2 # Chinese distractor
        return choice_text==self.get_target_word_by_pair_id(pair_id, lang)
      end
    end
    return false
  end
  
end