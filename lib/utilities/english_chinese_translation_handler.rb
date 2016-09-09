module Utilities::EnglishChineseTranslationHandler
  HASH_KEY_PREFIX = "englishchinesetranslation"

  def self.get_cn_id_by_en_id_and_postag( eng_vocab_id, pos_tag )
    # EnglishChineseTranslation.where('english_vocabulary_id=? AND pos_tag=? AND frequency_rank=0',
    #                 word.word_id, POS_INDEX[word.pos_tag]).pluck(:chinese_vocabulary_id)

    hash_key = HASH_KEY_PREFIX + "_eng_id_" + eng_vocab_id.to_s + "_pos_tag_" + pos_tag.to_s + "_freq_rank_0"
    Rails.cache.fetch( hash_key ) do
      EnglishChineseTranslation.where('english_vocabulary_id=? AND pos_tag=? AND frequency_rank=0',
                                      eng_vocab_id , pos_tag).pluck(:chinese_vocabulary_id)
    end

  end

  def self.get_trans_id_by_eng_id_and_ch_id( eng_vocab_id, ch_vocab_id )

    # EnglishChineseTranslation.where(english_vocabulary_id: source_word_id,
    #                                chinese_vocabulary_id: target_word_id).pluck(:id).first

    hash_key = HASH_KEY_PREFIX + "_eng_id_" + eng_vocab_id.to_s + "_ch_id_" + ch_vocab_id.to_s

    Rails.cache.fetch( hash_key) do
      EnglishChineseTranslation.where(english_vocabulary_id: eng_vocab_id,
                                      chinese_vocabulary_id: ch_vocab_id).pluck(:id).first
    end

  end

end