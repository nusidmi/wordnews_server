module Bing
	# Specify all arguments
	def Bing.translate(texts, from, to)
		if !ENV["bingid"].present? || !ENV["bingkey"].present? || !ENV["bingaccount"].present?
			Rails.logger.warn "Bing_translator: Init failed. env missing"
			return false
		end

		begin
			translator = BingTranslator.new(ENV["bingid"], ENV["bingkey"], false, ENV["bingaccount"])
			chinese = translator.translate_array2 texts, :from => from, :to => to #'zh-CHS'

		rescue BingTranslator::AuthenticationException
			Rails.logger.warn "Bing_translator: Authentication Error"
			return false

		end

		return chinese
	end

	def speak(text, language)
		audio = translator.speak text, :language => language, :format => 'audio/mp3', :options => 'MaxQuality'
		open(text+'.mp3', 'wb') { |f| f.write audio }
		translator.balance # => 20000

	end

	def get_access_token
	  begin
	    translator = BingTranslator.new('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET', false, 'AZURE_ACCOUNT_KEY')
	    token = translator.get_access_token
	    token[:status] = 'success'
	  rescue Exception => exception
	    YourApp.error_logger.error("Bing Translator: \"#{exception.message}\"")
	    token = { :status => exception.message }
	  end
	  token
	end
end
