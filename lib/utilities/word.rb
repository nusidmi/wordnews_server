class Utilities::Word
  
  def initialize (text, paragraph_index, sentence_index, word_index)
    @text = text
    @paragraph_index = paragraph_index
    @sentence_index = sentence_index
    @word_index = word_index  # the occurence index in the paragraph
  end
  
  def set_translation(translation)
    @translation = translation
  end
  
  attr_reader :text, :paragraph_index, :sentence_index, :word_index, :translation
  
end