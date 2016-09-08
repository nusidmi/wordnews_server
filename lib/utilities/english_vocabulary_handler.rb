module Utilities::EnglishVocabularyHandler
  HASH_KEY_PREFIX = "englishvocabulary"

  def self.get_id_by_word( word )

    # EnglishVocabulary.where(text: word).pluck(:id).first
    hash_key = HASH_KEY_PREFIX + "_id_by_text_" + word.to_s

    Rails.cache.fetch( hash_key) do
      EnglishVocabulary.where(text: word).pluck(:id).first
    end

  end


end