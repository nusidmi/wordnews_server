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
    ret_num = 2   # Default 2

    if !num.present?
      Rails.logger.debug "validate_input_num_words; num_words missing -> default to 2"
      return ret_num # If params is missing, Default 2
    end

    if !/\A\d+\z/.match(num)
      Rails.logger.debug "validate_input_num_words; num_word is not integer -> default to 2"
      return ret_num # If params is missing, Default 2
    end

    ret_num = num.to_i

    # Limit check. 1 - 10
    ret_num = [10, [1, ret_num].max].min
    Rails.logger.debug "validate_input_num_words; num_words=[" + ret_num.to_s + ']'

    return ret_num
  end

end