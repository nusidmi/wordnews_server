module Utilities::ChineseAnnotationVocabularyHandler
  HASH_KEY_PREFIX = "chineseannotationvocabulary"


  def self.get_pronunciation_by_word(word)
    hash_key = HASH_KEY_PREFIX + "_pronun_by_text_" + word.to_s

    Rails.cache.fetch( hash_key) do
      ChineseAnnotationVocabulary.where(text: word).pluck(:pronunciation).first
    end

  end
  
end
