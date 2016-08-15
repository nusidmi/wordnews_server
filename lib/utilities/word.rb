class Utilities::Word
  
  def initialize (text, paragraph_index, sentence_index, word_index)
    @text = text
    @paragraph_index = paragraph_index
    @sentence_index = sentence_index
    @word_index = word_index  # the occurence index in the paragraph
  end
  
  # the id in the english_words
  def get_word_db_id
    word = @text.downcase.singularize
    @word_db_id = EnglishWords.find_by(english_meaning: word)
    return @word_db_id
  end
  
  
  attr_reader :text, :paragraph_index, :sentence_index, :word_index,
              :word_db_id, :translation_db_id, :meaing_db_id
  
end