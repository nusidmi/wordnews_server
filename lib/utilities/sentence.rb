class Utilities::Sentence
    def initialize (text, word_tag_str, paragraph_index, sentence_index)
        @text = text
        @paragraph_index = paragraph_index
        @sentence_index = sentence_index
        parse(word_tag_str)
    end
    
    def get_word_frequncy(word, word_index)
        freq = 0
        i = 0
        if word_index.nil?
            word_index = @words.size()
        end
        while i<word_index
            if @words[i]==word
                freq += 1
            end
            i += 1
        end
        return freq
    end
    
    # The format of word_tag_str is [('word','tag'),('word','tag'),...]
    def parse(word_tag_str)
        @words = []
        @tags = []
        
        tuples = word_tag_str[1..-3].split(/\),\s?\(/)
        
        tuples.each do |tuple|
            pair = tuple[1..-2].split(/\',\s?\'/)  
            @words.push(pair[0])
            @tags.push(pair[1])
        end
    end
    
    attr_reader :text, :words, :tags, :paragraph_index, :sentence_index
end