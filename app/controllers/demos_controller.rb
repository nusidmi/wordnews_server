class DemosController < ApplicationController
  
  # generate some dummy data to test frontend
  def show_learn_words
    @words_to_learn = []
    
    # http://www.bbc.com/sport/cricket/36853346
    article_id = 3
    
    
    # a word to view translation
    # word_text, paragraph_idx, sentence_idx, word_idx, word_id, word_pos
    word = Utilities::Word.new('appear', 4, -1, 0, 152, 'VB', [-1,-1])
    word.weighted_vote = 1
    word.learn_type = 'view'
    wrap_word(word)
    get_annotations(word, article_id, 'zh_CN')
    @words_to_learn.push(word)
    
    
    # a word to take quiz
    word = Utilities::Word.new('growth', 5, -1, 0, 3843, 'NN', [-1,-1])
    word.weighted_vote = 1
    word.learn_type = 'test'
    wrap_word(word)

    word.quiz = Utilities::LearningUtil.generate_quiz_chinese(word.text)
    @words_to_learn.push(word)
    
    # response
    respond_to do |format|
      format.json { render json: { msg: Utilities::Message::MSG_OK, words_to_learn: @words_to_learn}, 
                    status: :ok }
    end
    
  end
 
 
  def wrap_word(word)
    mt_result = get_dict_translation(word)
    word.machine_translation_id = mt_result[0]
    word.translation = mt_result[1]
    
    word.translation_id = Utilities::LearningUtil.get_word_id(word.translation, 'zh_CN')
    word.pair_id = Utilities::LearningUtil.get_translation_pair_id(word.word_id, word.translation_id, 'zh_CN')
    word.pronunciation = Utilities::LearningUtil.get_pronunciation_by_word_id(word.translation_id, 'zh_CN')
    word.audio_urls = Utilities::LearningUtil.get_audio_urls(word.pronunciation, 'zh_CN')
    
  end
 

  def get_dict_translation(word)
    translation_id = EnglishChineseTranslation.where('english_vocabulary_id=? AND pos_tag=? AND frequency_rank=0', 
                    word.word_id, POS_INDEX[word.pos_tag]).pluck(:chinese_vocabulary_id)
    translation = ChineseVocabulary.where(id: translation_id).pluck(:text).first
    return [translation_id, translation]
  end
  
  
  def get_annotations(word, article_id, lang)
    if word.learn_type=='view'
      word.annotations = Annotation.where('article_id=? AND paragraph_idx=? AND text_idx=? AND selected_text=?',
          article_id, word.paragraph_index, word.word_index, word.text).order('vote + 0.1*implicit_vote DESC').limit(ANNOTATION_COUNT_MAX).pluck_all(:id, :translation, :vote, :implicit_vote)
      if !word.annotations.nil?
        word.annotations.each do |annotation|
          annotation['pronunciation'] = Utilities::LearningUtil.get_pronunciation_by_word(annotation['translation'], lang)
          annotation['audio_urls'] = Utilities::LearningUtil.get_audio_urls(annotation['pronunciation'], lang)
          annotation['weighted_vote'] = Utilities::LearningUtil.get_weighted_vote(annotation['vote'], annotation['implicit_vote'])
        end
      end
    end
  end
  
end
