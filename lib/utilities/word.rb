class Utilities::Word
  
  def initialize (text, paragraph_index, sentence_index, word_index, word_id, pos_tag, position)
    @text = text
    @paragraph_index = paragraph_index
    @sentence_index = sentence_index
    @word_index = word_index  # the occurence index in the paragraph
    @word_id = word_id
    @pos_tag = pos_tag
    @position = position # [start, end]: the character index in the sentence
  end
  
  # the id in the english_words
  def get_word_id
    word = @text.downcase.singularize
    @word_id = EnglishWords.find_by(english_meaning: word)
    return @word_id
  end
  
  
  
  
  attr_accessor :text, :paragraph_index, :sentence_index, :word_index, :position,
              :pos_tag, :translation, :pronunciation, :word_id, :translation_id, 
              :pair_id, :weighted_vote, :learn_type, :quiz, :annotations, :audio_urls,
              :machine_translation_id # the id in machine_translations table
end