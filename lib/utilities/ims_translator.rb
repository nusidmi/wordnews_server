require 'httparty'
require 'json'

module Utilities::ImsTranslator
  @@IMS_FLAG = '_____'
  
  def self.translate(word, word_position, sentence)
    sentence = sentence[0..(word_position[0]-1)] + @@IMS_FLAG + sentence[word_position[0]..-1]
    params = {"sentence": sentence, 'word': word}
    response = HTTParty.post(IMS_HOST+'/translate_word', :query=>params)
    
    if response.code!=200 or response.body==''
      puts 'Error in calling IMS for ' + word
      return
    end
    
    result = JSON.parse(response.body)
    if result['msg']=='OK'
      return result['translation']
    end
  end
end
