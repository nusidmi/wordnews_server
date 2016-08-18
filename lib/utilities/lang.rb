module Utilities::Lang
    require 'json'
    
    CODE = {English: 'en', Chinese: 'zh_CN'}

    def self.get_language_name(lcode)
        if @code_lang.length==0
            file = File.read('"#{Rails.root}/public/data/lang.json')
            @code_lang = JSON.parse(file)
            @code_lang[code]
        else
            @code_lang[code]
        end
    end
    
    
end