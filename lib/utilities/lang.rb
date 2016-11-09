module Utilities::Lang
    require 'json'
    
    # rename to LANG_TO_CODE
    CODE = {English: 'en', Chinese: 'zh_CN'}
    CODE_TO_LANG = {'en': 'English', 'zh_CN': 'Chinese'}

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