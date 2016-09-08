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
        return Utilities::ChineseVocabularyHandler.get_pronunciation_by_word( word)
      end
    end
  end
  
  
  # TODO: design the rule
  # view/test/skip the word based on user's learning history
  def self.get_learn_type(user_id, pair_id, lang)
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
  def self.get_weighted_vote(explicit_vote, implicit_vote)
    return explicit_vote + 0.1 * implicit_vote
  end
  
  
   # TODO: remove category
  def self.generate_quiz_chinese(word_text)
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
  
end