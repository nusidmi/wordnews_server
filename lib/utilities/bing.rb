module Bing
	# Specify all arguments
	
	# Translate paragraphs
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
		rescue Exception => e
			Rails.logger.warn "Bing_translator: Error e.msg=>[" + e.message + "]"
			return false
		end

		return chinese
	end
	
	
	# Translate one word in a sentence
	# English -> Chinese
	def Bing.translate_word(word_position, sentence, from, to)
		if !ENV["bingid"].present? || !ENV["bingkey"].present? || !ENV["bingaccount"].present?
			Rails.logger.warn "Bing_translator: Init failed. env missing"
		end

		begin
			translator = BingTranslator.new(ENV["bingid"], ENV["bingkey"], false, ENV["bingaccount"])
			result = translator.translate_array2 sentence, :from => from, :to => to #'zh-CHS'
			if !result.nil?
				translation_sentence = result[0][0]
				puts translation_sentence
				alignments = result[0][1] # E.g., 0:3-0:0 5:6-1:1 8:9-2:3 11:17-4:5 18:18-6:6
				puts alignments

			  alignments.split(' ').each do |mapping|
			  	pairs = mapping.split('-')
			  	source_range = pairs[0].split(':')
			  	target_range = pairs[1].split(':')
			  	
			  	if source_range[0].to_i==word_position[0] and source_range[1].to_i==word_position[1]
			  		return translation_sentence[target_range[0].to_i..target_range[1].to_i]
			  	elsif source_range[1].to_i>word_position[0]
			  		return 
			  	end
			  end
			end
			
		rescue BingTranslator::AuthenticationException
			Rails.logger.warn "Bing_translator: Authentication Error"
		rescue Exception => e
			Rails.logger.warn "Bing_translator: Error e.msg=>[" + e.message + "]"
		end
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
	
	
	def parse_alignment_string(alignments)
    aligned_positions = Hash.new
    alignments.split(' ').each do |mapping|
      lhs = mapping.split('-')[0]
      start_of_lhs = lhs.split(':')[0]

      rhs = mapping.split('-')[1]
      start_of_rhs = rhs.split(':')[0]
      end_of_rhs = rhs.split(':')[1]

      aligned_positions[start_of_lhs.to_i] = [start_of_rhs.to_i, end_of_rhs.to_i]
    end
    aligned_positions
  end


end
