require 'chinese_pinyin'

module Utilities::AnnotationUtil
  
  # TODO: cache
  def self.save_pronunciation(annotation, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      if ChineseVocabularyHandler.get_pronunciation_by_word(annotation).nil? and \
        ChineseAnnotationVocabularyHandler.get_pronunciation_by_word(annotation).nil?
        pron = get_pronunciation_from_tool(annotation)
        if !pron.nil?
          voc = ChineseAnnotationVocabulary.new(text: annotation, pronunciation: pron)
          voc.save
        end
      end
    end
  end
  
  def self.get_pronunciation_by_word(annotation, lang)
    if lang==Utilities::Lang::CODE[:Chinese]
      return Utilities::ChineseVocabularyHandler.get_pronunciation_by_word(annotation) ||
            Utilities::ChineseAnnotationVocabularyHandler.get_pronunciation_by_word(annotation) ||
            get_pronunciation_from_tool(annotation)
    end
  end
  
  
  def self.get_pronunciation_from_tool(annotation)
    begin 
      return Pinyin.t(annotation, tone: true)
    rescue Exception => e
      puts "caught exception #{e}! in get pronunciation!"
      Rails.logger.warn "Cannot obtain pronunciation for " + annotation
    end
  end
end