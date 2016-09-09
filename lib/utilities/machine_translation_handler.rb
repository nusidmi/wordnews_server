module Utilities::MachineTranslationHandler
  HASH_KEY_PREFIX = "machine_translation"

  def self.get_translation_by_id( id )

    # MachineTranslation.find_by_id(params[:translation_pair_id])
    hash_key = HASH_KEY_PREFIX + "_translation_by_id_" + id.to_s

    machine_translation =  Rails.cache.read(hash_key)
    if machine_translation.nil?
      machine_translation = MachineTranslation.find_by_id(id)

      if !machine_translation.nil?
        Rails.cache.write(hash_key, machine_translation)
      end
    end

    return machine_translation

  end

  def self.get_id_transl_votes_by_params1( article_id, paragraph_index, text_idx, translator, lang, text )
    # MachineTranslation.where(article_id: article_id, paragraph_idx: word.paragraph_index,
    #  text_idx: word.word_index, translator: translator, lang: lang, text:word.text).pluck_all(:id, :translation, :vote, :implicit_vote).first

    hash_key = HASH_KEY_PREFIX + "_transl_id_votes_by_art_id_" + article_id.to_s + "_para_idx_" + paragraph_index.to_s + "_text_idx_" +text_idx.to_s + "_trans_" + translator.to_s + "_lang_" + lang.to_s + "_text_" + text.to_s

    machine_translation =  Rails.cache.read(hash_key)
    if machine_translation.nil?
      machine_translation = MachineTranslation.where(article_id: article_id, paragraph_idx: paragraph_index,
                                                     text_idx: text_idx, translator: translator, lang: lang, text: text).pluck_all(:id, :translation, :vote, :implicit_vote).first

      if !machine_translation.nil?
        Rails.cache.write(hash_key, machine_translation)
      end
    end

    return machine_translation

  end

end