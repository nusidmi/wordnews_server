#!bin/env ruby
#encoding: utf-8
require 'json'

class TranslatesController < ApplicationController
  #include UserHandler
  #include Bing

  def replacements_by_dictionary

    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    user_name = params[:name]
    url = params[:url] || ''
    url = url.chomp '/'

    # Validate userID
    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validating URL
    if !ValidationHandler.validate_url(params[:url])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate text
    if !ValidationHandler.validate_input_text(params[:text])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate num_words include limit check
    num_words = ValidationHandler.validate_input_num_words(params[:num_words])

    user = User.where(:user_name => user_name).first
    if user.nil?
      Rails.logger.warn "do_replacements_by_dictionary: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    user_id = user.id

    #category_list = user.translate_categories.split(",")
    ret_translate = dictionary_translation(user_id, num_words, params[:text])

    if ret_translate.empty?
      Rails.logger.debug "do_replacements_by_dictionary; No translation found but we still return OK"
    end

    result['translate_text'] = ret_translate
    result['msg'] = Utilities::Message::MSG_OK

    render json: result
  end

  def translate_paragraphs(user_id, num_words, paragraphs, prioritise_hardcode = false)
    results = []

    chinese_sentences_with_alignments = Bing.translate(paragraphs, 'en', 'zh-CHS')
    if chinese_sentences_with_alignments == false
      Rails.logger.debug "translate_paragraphs; Bing did not generate any translation result"
      return []
    end

    #puts "Translated text from Bing >>>>" + chinese_sentences_with_alignments.to_s

    paragraphs.zip(chinese_sentences_with_alignments).each do |paragraph, chinese_sentence_with_alignment|
      result = Hash.new
      chinese_sentence = chinese_sentence_with_alignment[0]
      raw_alignment = chinese_sentence_with_alignment[1]

      if chinese_sentence.nil?   # Check if chinese sentence is missing
        Rails.logger.debug "translate_paragraphs; Chinese sentence missing"
        next
      end
      if raw_alignment.nil?   # It is possible that raw alignment data is missing
        Rails.logger.debug "translate_paragraphs; Raw alignment missing"
        next
      end

      if !paragraph.blank?
        alignment = parse_alignment_string(raw_alignment)

        words_retrieved = 0
        index_offset = 0

        paragraph.split(' ').each do |orig_word|
          word = orig_word.gsub(/[^a-zA-Z]/, '')
          if words_retrieved >= num_words
            #Rails.logger.debug "translate_paragraphs; No need to continue as num_words is the number of words requested by the client"
            break # no need to continue as num_words is the number of words requested by the client
          end


          normalised_word = word.downcase.singularize
          english_meaning = EnglishWords.joins(:meanings)
                                .select('english_meaning, english_words.id as english_word_id, meanings.id, meanings.chinese_words_id, meanings.word_category_id')
                                .where('english_meaning = ?', normalised_word).first

          zh_word = ''
          if english_meaning.nil?
            # no such english word in our dictionary
            #Rails.logger.debug "translate_paragraphs; No such english word in our dictionary"
            next
          else
            word_index = paragraph.index(orig_word, index_offset)
            index_offset = word_index || index_offset # this is to handle multiple occurrences of the same word in the text
            # don't change index_offset if word_index is nil, which should not happen

            chinese_alignment_pos_start, pos_end = alignment[word_index]

            if pos_end.nil?
              #Rails.logger.debug "translate_paragraphs; No end position"
              next
            end
            zh_word = chinese_sentence[chinese_alignment_pos_start.. pos_end]

            # find meaning using the chinese word given by bing
            actual_meaning = chinese_meaning(normalised_word, zh_word)

            if actual_meaning.nil?
              #Rails.logger.debug "translate_paragraphs; No actual meaning"
              next
            end

          end

          @original_word_id = actual_meaning.nil? ? english_meaning.id : actual_meaning.id

          result[word] = Hash.new

          testEntry = Meaning.joins(:histories)
                          .select('meaning_id, frequency')
                          .where('user_id = ? AND meaning_id = ?', user_id, @original_word_id).first


          result[word]['wordID'] = @original_word_id # pass id of meaning to the client

          if testEntry.blank? or testEntry.frequency.to_i < QUIZ_FREQUENCY_COUNT_MIN #just translate the word
            if prioritise_hardcode
              # check if a hard-coded translation is specified for this word
              hard_coded_word = HardCodedWord.where(:url => @url, :word => normalised_word)
              if hard_coded_word.length > 0
                if hard_coded_word.first.translation?
                  result[word]['chinese'] = hard_coded_word.first.translation
                else
                  result.delete(word)
                  next
                end
              end
              if hard_coded_word.length == 0
                result[word]['chinese'] = actual_meaning.chinese_meaning
              end
            else
              result[word]['chinese'] = actual_meaning.chinese_meaning
            end

            words_retrieved = words_retrieved + 1

            result[word]['pronunciation'] = ''

            possible_pronunciation = ChineseWords.where('chinese_meaning = ?', actual_meaning.chinese_meaning)
            if possible_pronunciation.length > 0
              result[word]['pronunciation'] = possible_pronunciation.first.pronunciation.strip
            end

            result[word]['isTest'] = 0
            result[word]['testType'] = 0
            result[word]['position'] = word_index  ## How come we only need to set the position in this testType and not others???

          elsif testEntry.frequency.to_i.between?(QUIZ_FREQUENCY_COUNT_MIN, QUIZ_FREQUENCY_COUNT_MAX)
            result[word]['isTest'] = 1
            result[word]['testType'] = 1
            result[word]['chinese'] = actual_meaning.chinese_meaning

            result[word]['choices'] = Hash.new
            choices = Meaning.where(:word_category_id => english_meaning.word_category_id)
                          .where('english_words_id != ?', actual_meaning.english_word_id)
                          .order('RANDOM()')
                          .first(3)
            choices.each_with_index { |val, idx|
              result[word]['choices'][idx.to_s] = EnglishWords.find(val.english_words_id).english_meaning
            }
            result[word]['isChoicesProvided'] = !(choices.empty?)

          else

            result[word]['isTest'] = 2
            result[word]['testType'] = 2
            result[word]['isChoicesProvided'] = true
            result[word]['chinese'] = actual_meaning.chinese_meaning

            result[word]['choices'] = Hash.new
            choices = Meaning.where(:word_category_id => english_meaning.word_category_id)
                          .where('chinese_words_id != ?', actual_meaning.chinese_words_id)
                          .order('RANDOM()')
                          .first(3)
            choices.each_with_index { |val, idx|
              result[word]['choices'][idx.to_s] = ChineseWords.find(val.chinese_words_id).chinese_meaning
            }

          end

        end # end of for word in word_list
      end

      results.push(result)
    end
    results
  end

  def replacements_by_bing
    # Validate username and url

    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    user_name = params[:name]
    url = params[:url] || ''
    url = url.chomp '/'

    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validating URL
    if !ValidationHandler.validate_url(params[:url])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate text
    if !ValidationHandler.validate_input_text(params[:text])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate num_words include limit check
    num_words = ValidationHandler.validate_input_num_words(params[:num_words])

    user = User.where(:user_name => user_name).first
    if user.nil?
      Rails.logger.warn "do_replacements_by_bing: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    user_id = user.id

    ret_translate = translate_paragraphs(user_id, num_words, [params[:text]])

    if ret_translate.empty? || ret_translate[0].empty?
      Rails.logger.debug "do_replacements_by_bing; No translation found but we still return OK"
      result['translate_text'] = []

    else
      result['translate_text'] = ret_translate[0]
    end

    result['msg'] = Utilities::Message::MSG_OK
    render json: result
  end

  def replacements_multiple_paragraphs_by_bing

    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    user_name = params[:name]
    url = params[:url] || ''
    url = url.chomp '/'

    # Validate userID
    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validating URL
    if !ValidationHandler.validate_url(params[:url])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate text
    if !ValidationHandler.validate_input_text(params[:texts])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validate num_words include limit check
    num_words = ValidationHandler.validate_input_num_words(params[:num_words])

    user = User.where(:user_name => user_name).first
    if user.nil?
      Rails.logger.warn "do_replacements_multiple_paragraphs_by_bing: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    user_id = user.id

    paragraphs = JSON.parse(params[:texts])

    ret_translate = []
    paragraphs.each_slice(5) { |slice|
      ret_translate.push(*translate_paragraphs(user_id, num_words, slice))
    }

    result['translate_text'] = ret_translate
    result['msg'] = Utilities::Message::MSG_OK

    render json: result

  end

  def chinese_meaning(english, chinese)
    actual_meanings = EnglishWords.joins(:chinese_words)
                          .select('english_meaning, meanings.id, english_words.id as english_word_id, meanings.chinese_words_id, meanings.word_category_id, chinese_meaning, pronunciation')
                          .where('english_meaning = ?', english)
    actual_meaning = nil
    # actual meanings contains the set of possible english-meaning-chinese words
    actual_meanings.each do |possible_actual_meaning|
      possible_chinese_match = possible_actual_meaning.chinese_meaning
      if possible_chinese_match == chinese
        actual_meaning = possible_actual_meaning
        break
      end

    end
    actual_meaning
  end


  def get_example_sentences
    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    # Validating word
    if !ValidationHandler.validate_input_wordID(params[:wordID])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    meaning_id = params[:wordID]

    sentence_list = MeaningsExampleSentence.where(:meaning_id => meaning_id)

    result['chineseSentence'] = Hash.new
    result['englishSentence'] = Hash.new
    sentence_list.each_with_index { |val, idx|
      result['chineseSentence'][idx.to_s] = ExampleSentence.find(val.example_sentences_id).chinese_sentence
      result['englishSentence'][idx.to_s] = ExampleSentence.find(val.example_sentences_id).english_sentence
    }

    result['msg'] = Utilities::Message::MSG_OK

    return render json: result
  end

  # get /getQuiz
  def quiz
    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    # Validating word
    if !ValidationHandler.validate_input_word(params[:word])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end
    word_under_test = params[:word]

    # Validating category
    if !ValidationHandler.validate_input_category(params[:category])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end
    category = params[:category]

    # Validating level
    if !ValidationHandler.validate_input_level(params[:level])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end
    level = params[:level]

    begin
      distractors_str = `python "public/MCQ Generation/MCQGenerator.py" #{category} #{level} #{word_under_test}`
    rescue Exception => e
      Rails.logger.warn "MCQGenerator.py: Error e.msg=>[" + e.message + "]"
      result['msg'] = Utilities::Message::MSG_GET_QUIZ_ERROR_IN_GENERATION
      return render json: result, status: :internal_server_error
    end

    distractors = distractors_str.split(',')
    Rails.logger.debug "#{word_under_test} has  #{distractors.size} distractors"

    quiz = Hash.new

    quiz[word_under_test] = Hash.new
    quiz[word_under_test]['isTest'] = 1 # TODO rename isTest to testType
    quiz[word_under_test]['choices'] = Hash.new

    distractors.each_with_index { |val, idx|
      quiz[word_under_test]['choices'][idx.to_s] = val.strip
    }

    hard_coded_quiz = HardCodedQuiz.where(:url => @url, :word => word_under_test)  ## <<--- is url needed???
    if hard_coded_quiz.length > 0

      quiz[word_under_test]['choices']['0'] = hard_coded_word.first.option1
      quiz[word_under_test]['choices']['1'] = hard_coded_word.first.option2
      quiz[word_under_test]['choices']['2'] = hard_coded_word.first.option3
    end

    result['quiz'] = quiz
    result['msg'] = Utilities::Message::MSG_OK

    return render json: result
  end


  def remember

    result = Hash.new
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    user_name = params[:name]
    url = params[:url] || ''
    url = url.chomp '/'

    # Validate userID
    if !UserHandler.validate_userID( user_name )
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validating URL
    if !ValidationHandler.validate_url(params[:url])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    # Validating isRemember
    if !ValidationHandler.validate_input_is_remember(params[:isRemembered])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    is_remember = params[:isRemembered].to_i

    # Validating wordID
    if !ValidationHandler.validate_input_wordID(params[:wordID])
      result['msg'] = Utilities::Message::MSG_INVALID_PARA
      return render json: result, status: :bad_request
    end

    meaning_id = params[:wordID]

    user = User.where(:user_name => user_name).first
    if user.nil?
      Rails.logger.warn "do_remember: User[" + user_name.to_s + "] not found"
      result['msg'] = Utilities::Message::MSG_SHOW_USER_NOT_FOUND
      return render json: result, status: :bad_request
    end

    user_id = user.id

    testEntry = History.where(:meaning_id => meaning_id, :user_id => user_id).first
    if not testEntry.blank? # the user has seen this word before, just change the if_understand field
      if is_remember == 0
        testEntry.frequency = 0
      else
        testEntry.frequency= testEntry.frequency+1
      end
      # puts 'frequency of word with id = '
      # puts @user_id
      # puts 'wordID'
      # puts @meaning_id
      # puts testEntry.frequency

      testEntry.url = @url
      testEntry.save
    else # this is a new word the user has some operations on
      begin
        understand = History.new
        understand.user_id = user_id
        understand.meaning_id = meaning_id
        understand.url = url
        understand.frequency = is_remember
        understand.save
      rescue Exception => e
        Rails.logger.warn "do_remember: Error in creating History e.msg=>[" + e.message + "]"
        result['msg'] = Utilities::Message::MSG_REMEMBER_HISTORY_CREATE_ERROR
        return render json: result, status: :internal_server_error
      end
    end

    result['msg'] = Utilities::Message::MSG_OK
    return render json: result

  end

  def calculate

    isNameValid = false
    user_name = ''
    user = nil

    # If name is provided,
    # 1. Test if userID is valid - 16 character, lowercase, hex
    # 2. Check for user account

    if params.has_key?(:name)
      user_name = params[:name]
      if UserHandler.validate_userID(user_name)
        user = User.where(:user_name => user_name).first
        if !user.blank?
          # User is not found
          isNameValid = true
        end
      end
    end

    result = Hash.new
    result['userID'] = -1
    result['msg'] = Utilities::Message::MSG_GENERAL_FAILURE

    result['learnt'] = 0
    result['toLearn'] = 0

    if isNameValid == false
      user = UserHandler.create_new_user()
      if !user.nil?
        result['userID'] = user.user_name.to_i
        result['msg'] =  Utilities::Message::MSG_OK
      else
        result['msg'] =  Utilities::Message::MSG_GET_CALCULATE_USER_CREATE_FAILURE
        return render json: result, status: :internal_server_error
      end
    else
      user_id = user.id
      querylearnt = 'user_id=' + user_id.to_s+ ' and frequency > 0'
      querytolearn = 'user_id=' + user_id.to_s+ ' and frequency = 0'

      result['learnt'] = History.count('user_id', :conditions => [querylearnt])
      result['toLearn'] = History.count('user_id', :conditions => [querytolearn])
      result['userID'] = user.user_name.to_i

      result['msg'] =  Utilities::Message::MSG_OK
    end

    render json: result
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

  def dictionary_translation(user_id, num_words, paragraphs, prioritise_hardcode = false)
    result = Hash.new

    word_list = paragraphs.split(' ')
    #chinese_sentence = ''
    words_retrieved = 0
    for word in word_list
      word = word.gsub(/[^a-zA-Z]/, "")
      if words_retrieved >= num_words
        #Rails.logger.debug "dictionary_translation; No need to continue as num_words < words_retrieved"
        break # no need to continue as @num_words is the number of words requested by the client
      end

      #this is to add downcase and singularize support
      original_english_word = word.downcase.singularize

      english_meaning_row = EnglishWords.joins(:meanings)
                                .select('english_meaning, meanings.id, meanings.chinese_words_id, meanings.word_category_id')
                                .where("english_meaning = ?", original_english_word)

      # english_meaning = nil
      if english_meaning_row.length == 0
        #Rails.logger.debug "dictionary_translation; No english meaning found"
        next
      elsif english_meaning_row.length == 1 #has one meaning
        english_meaning = english_meaning_row.first
      else
        # multiple matching meanings
        english_meaning = english_meaning_row.first # take the first meaning by default, unless a sentence matches

        # Not used?
        # english_meaning_row.length.times do |index|
        #   # checks if the bing-translated chinese sentence contains the chinese word retrieved
        #   if chinese_sentence.to_s.include? ChineseWords.find(english_meaning_row[index].chinese_words_id).chinese_meaning
        #     english_meaning = english_meaning_row[index]
        #     break
        #   end
        # end
      end

      result[word] = Hash.new

      @original_word_id = english_meaning_row.first.id

      #if temp.chinese_words_id.nil?
      #  english_meaning = meanings[0]
      #end

      # if this point is reached, then the word and related information is sent back
      words_retrieved = words_retrieved + 1

      @original_word_chinese_id = english_meaning.chinese_words_id


      result[word]['wordID'] = english_meaning.id # always pass meaningId to client
      chinese_word = ChineseWords.find(english_meaning.chinese_words_id)

      result[word]['chinese'] = chinese_word.chinese_meaning

      result[word]['pronunciation'] = chinese_word.pronunciation


      # see if the user understands this word before
      testEntry = Meaning.joins(:histories)
                      .select('meaning_id, frequency')
                      .where("user_id = ? AND meaning_id = ?", user_id, english_meaning.id).first


      if testEntry.blank? or testEntry.frequency.to_i < QUIZ_FREQUENCY_COUNT_MIN #just translate the word
        result[word]['isTest'] = 0

      elsif testEntry.frequency.to_i.between?(QUIZ_FREQUENCY_COUNT_MIN, QUIZ_FREQUENCY_COUNT_MAX) # quiz
        result[word]['isTest'] = 1
        result[word]['choices'] = Hash.new
        result[word]['isChoicesProvided'] = true

        choices = Meaning.where(:word_category_id => english_meaning.word_category_id).where("english_words_id != ?", @original_word_id).random(3)
        choices.each_with_index { |val, idx|
          result[word]['choices'][idx.to_s] = EnglishWords.find(val.english_words_id).english_meaning
        }


      else
        result[word]['isTest'] = 2
        result[word]['choices'] = Hash.new
        result[word]['isChoicesProvided'] = true

        choices = Meaning.where(:word_category_id => english_meaning.word_category_id).where("chinese_words_id != ?", @original_word_chinese_id).random(3)
        choices.each_with_index { |val, idx|
          result[word]['choices'][idx.to_s] = ChineseWords.find(val.chinese_words_id).chinese_meaning
        }

      end

    end # end of for word in word_list

    return result
  end
end
