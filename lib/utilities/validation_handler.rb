module ValidationHandler

  def ValidationHandler.validate_url(url)
    if !url.present?
      Rails.logger.debug "validate_url; url is empty string"
      return false
    end

    begin
      !!URI.parse(url)
    rescue URI::InvalidURIError
      Rails.logger.debug "validate_url; URI::InvalidURIError"
      return false
    end

    return true
  end

  def ValidationHandler.validate_input_text(text)
    # Validate input text
    if !text.present?
      Rails.logger.debug "validate_input_text; Text missing"
      return false
    end
    return true
  end

  def ValidationHandler.validate_input_num_words(num)
    # Validate input num_words
    ret_num = NUM_OF_WORDS_TO_TRANSLATE_DEFAULT   # Default 2

    if !num.present?
      Rails.logger.debug "validate_input_num_words; num_words missing -> default to 2"
      return ret_num # If params is missing, Default 2
    end

    if !/\A\d+\z/.match(num)
      Rails.logger.debug "validate_input_num_words; num_word is not positive integer -> default to 2"
      return ret_num # If params is missing, Default 2
    end

    ret_num = num.to_i

    # Limit check. 1 - 10
    ret_num = [NUM_OF_WORDS_TO_TRANSLATE_MAX, [NUM_OF_WORDS_TO_TRANSLATE_MIN, ret_num].max].min
    Rails.logger.debug "validate_input_num_words; num_words=[" + ret_num.to_s + ']'

    return ret_num
  end

  def ValidationHandler.validate_input_is_remember(isRemember)
    # Validate input isRemember
    if !isRemember.present?
      Rails.logger.debug "validate_input_is_remember; isRemember missing"
      return false
    end

    if !/\A\d+\z/.match(isRemember)
      Rails.logger.debug "validate_input_is_remember; isRemember is not positive integer"
      return false
    end
    return true
  end

  def ValidationHandler.validate_input_wordID(wordID)
    # Validate input isMeaning
    if !wordID.present?
      Rails.logger.debug "validate_input_wordID; wordID missing"
      return false
    end

    if !/\A\d+\z/.match(wordID)
      Rails.logger.debug "validate_input_wordID; wordID is not positive integer"
      return false
    end

    # id = wordID.to_i
    # if id  > 2147483647 || id < 1
    #   Rails.logger.debug "validate_input_wordID; wordID is out of integer range of PostgresSQL"
    #   return false
    # end
    return true
  end

  def ValidationHandler.validate_input_word(word)
    # Validate input word
    if !word.present?
      Rails.logger.debug "validate_input_word; word missing"
      return false
    end
    return true
  end

  def ValidationHandler.validate_input_category(category)
    # Validate input category
    if !category.present?
      Rails.logger.debug "validate_input_category; category missing"
      return false
    end
    return true
  end

  def ValidationHandler.validate_input_level(level)
    # Validate input level
    if !level.present?
      Rails.logger.debug "validate_input_level; level missing"
      return false
    end
    if !/\A\d+\z/.match(level)
      Rails.logger.debug "validate_input_level; level is not positive integer"
      return false
    end
    return true
  end

end