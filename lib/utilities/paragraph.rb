require 'yaml'
require 'httparty'
require 'json'


class Utilities::Paragraph
#class Paragraph

  def initialize (paragraph_index, text, article_id)
    @index = paragraph_index
    @text = text
    @article_id = article_id
    @sentences = []
  end
  
    
  def process_text_script()
    sentences_str = `python "./public/text_processing.py" sentence_segmenter "#{@text}"`
    if sentences_str=='ERROR'
      return []     
    end
    
    # TODO:　Psych::SyntaxError ((<unknown>): mapping values are not allowed in this context at line 2 column 52):
    print sentences_str
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
  
  
  def process_text()
    hash_key = "paragraph_nlp_reply_article_" + @article_id.to_s + "_idx_" + @index.to_s

    nlp_reply =  Rails.cache.read(hash_key)
    if nlp_reply.nil?
      params = {"text": @text}
      response = HTTParty.post(NLP_HOST+'/text_process',
                               :body=>params.to_json,
                               :headers => {'Content-Type' => 'application/json'})

      if response.code!=200 or response.body==''
        puts 'Error in processing ' + @text
        return []
      end
      Rails.cache.write(hash_key, response.body)
      results = JSON.parse(response.body)

      results.each_with_index do |result, result_index|
        s = Utilities::Sentence.new(result["sent"], result["words"], result["tags"], @index, result_index)
        @sentences.push(s)
      end

      return @sentences
    else
      results = JSON.parse(nlp_reply)

      results.each_with_index do |result, result_index|
        s = Utilities::Sentence.new(result["sent"], result["words"], result["tags"], @index, result_index)
        @sentences.push(s)
      end

      return @sentences
    end
    
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