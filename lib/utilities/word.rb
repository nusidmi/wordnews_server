class Utilities::Word
  
  def initialize (text, paragraph_index, sentence_index, word_index, word_id)
    @text = text
    @paragraph_index = paragraph_index
    @sentence_index = sentence_index
    @word_index = word_index  # the occurence index in the paragraph
    @word_id = word_id
  end
  
  # the id in the english_words
  def get_word_id
    word = @text.downcase.singularize
    @word_id = EnglishWords.find_by(english_meaning: word)
    return @word_id
  end
  
  
  
  
  attr_accessor :text, :paragraph_index, :sentence_index, :word_index, :translation, 
              :word_id, :translation_id, :pair_id, :learn_type, :quiz, :annotations
end