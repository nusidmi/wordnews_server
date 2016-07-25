require 'securerandom'

module UserHandler
  # TODO need session authentication for every request that touches data for user (e.g. learning history)

  # TODO make private, and only allow user creation if id_token is validated
  def make_user(user_name)
    newUser = User.new
    newUser.user_name = user_name
    newUser.if_translate = 1
    newUser.translate_categories = '1,2,3,4' # the default will be translate all
    newUser.save
    newUser
  end

  def make_user_with_google_check(id_token)
    google_email = email_if_google_id_valid(id_token)

    if google_email.blank?
      raise ArgumentError.new('Unable to validate google id token')
    else
      make_user google_email
    end
  end

  def email_if_google_id_valid(id_token)
    require 'net/http'

    response = Net::HTTP.get_response(URI('https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=' + id_token))
    json = JSON.parse(response.body)

    audience = ENV['google_client_id']
    alternate_audience = ENV['google_chrome_extension_client_id']

    valid = audience.strip == json['aud'] || alternate_audience.strip == json['aud']
    if valid
      json['email']
    else
      ''
    end

  end

  def self.generate_userID(size=16)
    SecureRandom.hex(size)
  end

  def self.validate_userID(userID)
    if userID == '' || userID == nil
      #self.logger.debug "validate_userID; ID is empty string"
      return false
    end
    if userID =~ /^([0-9a-f]{16})+$/
      #self.logger.info "validate_userID; Validated ID=[" + userID + "]"
      return true
    end
    #self.logger.debug "validate_userID; ID is not a 16 hex string"
    return false
  end

  def self.create_new_user()
    counter = 0
    newUser = nil

    # Generate random userID and try to insert to User table
    # Possible that userID is duplicated. So we try 5 times.

    begin
      newUser = User.new
      newUser.if_translate = 1
      newUser.translate_categories = '1,2,3,4' # the default will be translate all
      newUser.user_name = generate_userID()

      if newUser.new_record?
        if newUser.save
          break;
        end
      end
      newUser = nil
      counter+=1
    end while counter < 5

    # if newUser != nil
    #   self.logger.info "create_new_user: New user created! [Name:" + newUser.user_name + "] Tries:{" + counter.to_s + "}"
    # else
    #   self.logger.warn "create_new_user: ERROR: cannot create new user after " + counter.to_s + " trys"
    # end

    return newUser
  end

end
