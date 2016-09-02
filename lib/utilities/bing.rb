module Utilities::Bing
	# Specify all arguments
	
	# Translate paragraphs
	def self.translate(texts, from, to)
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
	def self.translate_word(word_position, sentence, from, to)
		if !ENV["bingid"].present? || !ENV["bingkey"].present? || !ENV["bingaccount"].present?
			Rails.logger.warn "Bing_translator: Init failed. env missing"
		end

		begin
		
			# translate the same sentence in the last call
			if @prev_sentence==sentence
				alignments = @prev_alignments
				translation_sentence = @prev_translation_sentence
				#puts 're-use'
			else
				translator = BingTranslator.new(ENV["bingid"], ENV["bingkey"], false, ENV["bingaccount"])
				result = translator.translate_array2 sentence, :from => from, :to => to #'zh-CHS'
				if !result.nil?
					translation_sentence = result[0][0]
					alignments = result[0][1] # E.g., 0:3-0:0 5:6-1:1 8:9-2:3 11:17-4:5 18:18-6:6
					
					@prev_sentence = sentence
					@prev_translation_sentence = translation_sentence
					@prev_alignments = alignments
					#puts translation_sentence
					#puts alignments
				end
			end
			
			if !translation_sentence.nil? and !alignments.nil?			
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
	

	def self.speak(text, language)
		audio = translator.speak text, :language => language, :format => 'audio/mp3', :options => 'MaxQuality'
		open(text+'.mp3', 'wb') { |f| f.write audio }
		translator.balance # => 20000

	end

	def self.get_access_token
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
	
	
	def self.parse_alignment_string(alignments)
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
