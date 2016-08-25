require 'yaml'

class Utilities::Paragraph
#class Paragraph

  def initialize (paragraph_index, text)
    @index = paragraph_index
    @text = text
    @sentences = []
  end
  
  # def initialize(text, sentences)
  #   @text = text
  #   @sentences = sentences
  # end
    
  # TODO: improve the efficiency
  def process_text()

    sentences_str = `python "./public/text_processing.py" sentence_segmenter "#{@text}"`
    if sentences_str=='ERROR'
      return []     
    end
    
    # TODO:　Psych::SyntaxError ((<unknown>): mapping values are not allowed in this context at line 2 column 52):
    #print sentences_str
    sentence_list = YAML.load(sentences_str)
    sentence_list.each_with_index do |sentence_text, sentence_index|
      word_tag_str = `python "./public/text_processing.py" pos_tagger "#{sentence_text}"`
      #puts word_tag_str
      if word_tag_str!='ERROR'
        s = Utilities::Sentence.new(sentence_text, word_tag_str, @index, sentence_index)
        @sentences.push(s)
      end
    end
    return @sentences
  end
  
  
  # the number of occurence before the current position
  def get_word_occurence_index(word, sentence_index, word_sentence_index)
    word_occurence = 0
    i = 0
    
    while i<sentence_index
      word_occurence += @sentences[i].get_word_frequncy(word, nil)
      i += 1
    end
    
    word_occurence += @sentences[sentence_index].get_word_frequncy(word, word_sentence_index)
    return word_occurence
  end
  
  
  attr_reader :index, :text

end