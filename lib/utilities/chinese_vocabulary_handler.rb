module Utilities::ChineseVocabularyHandler
  HASH_KEY_PREFIX = "chinesevocabulary"

  def self.get_id_by_word( word )

    # ChineseVocabulary.where(text: word).pluck(:id).first
    hash_key = HASH_KEY_PREFIX + "_id_by_text_" + word.to_s

    Rails.cache.fetch( hash_key ) do
      ChineseVocabulary.where(text: word).pluck(:id).first
    end

  end

  def self.get_ch_text_by_id( id )

    # ChineseVocabulary.where(id: translation_id).pluck(:text).first
    hash_key = HASH_KEY_PREFIX + "_text_by_id_" + id.to_s

    Rails.cache.fetch( hash_key ) do
      ChineseVocabulary.where(id: id).pluck(:text).first
    end

  end

  def self.get_pronunciation_by_word( word )

    # ChineseVocabulary.where(text: word).pluck(:pronunciation).first
    hash_key = HASH_KEY_PREFIX + "_pronun_by_text_" + word.to_s

    Rails.cache.fetch( hash_key) do
      ChineseVocabulary.where(text: word).pluck(:pronunciation).first
    end

  end

  def self.get_pronunciation_by_id( id )

    # ChineseVocabulary.where(id: word_id).pluck(:pronunciation).first
    hash_key = HASH_KEY_PREFIX + "_pronun_by_id_" + id.to_s

    Rails.cache.fetch( hash_key) do
      ChineseVocabulary.where(id: id).pluck(:pronunciation).first
    end

  end

end