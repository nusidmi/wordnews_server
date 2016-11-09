module Utilities::Message
    MSG_OK                                      = 'OK'                      # No error
    MSG_GENERAL_FAILURE                         = 'General failure'         # Default error msg. Not specified.

    MSG_INVALID_PARA                            = 'Invalid parameters'
    MSG_NOT_FOUND                               = 'Not found in database'
    MSG_UPDATE_FAIL                             = 'Update failed'
    MSG_DELETE_FAIL                             = 'Delete failed'
    MSG_VOTE_FAIL                               = 'Vote failed'
    MSG_INSUFFICIENT_RANK                       = 'Not enough rank'


    # /create_new_user
    MSG_CREATE_FAILURE                          = 'User creation failed'

    # /show
    MSG_SHOW_USER_NOT_FOUND                     = 'User not found'
    MSG_SHOW_TRANSLATION_ERROR                  = 'Error in Translation'

    # /remember
    MSG_REMEMBER_HISTORY_CREATE_ERROR           = 'Error in creating history'

    # /getQuiz.json
    MSG_GET_QUIZ_ERROR_IN_GENERATION            = 'Quiz generation error'

    # /sign_up
    MSG_MISSING_SIGN_UP_PARAMS                  = 'Please fill up all the fields.'
    MSG_INVALID_EMAIL                           = 'Please enter a valid email.'
    MSG_USER_NAME_MAX_LENGTH                    = 'Your name exceeds the maximum length of 255 characters.'
    MSG_EMAIL_MAX_LENGTH                        = 'Your email exceeds the maximum length of 255 characters.'
    MSG_EMAIL_DUPLICATE                         = 'This email has already registered. Use another email or login.'
    MSG_PASSWORD_IS_NOT_SAME                    = 'Passwords don\'t match. Please try again.'

    # /login
    MSG_MISSING_LOGIN_PARAMS                    = 'Please enter an email and password'
    MSG_EMAIL_NOT_FOUND                         = 'This email is not registered. Use another email address or sign up to our service.'
    MSG_EMAIL_PASSWORD_NOT_CORRECT              = 'The email and password you entered don\'t match.'

    # Sign up by social
    MSG_SOCIAL_SIGNUP_ACCOUNT_ALREADY_REGISTERED    = 'This account has already be registered'

    # Login by social
    MSG_SOCIAL_LOGIN_ACCOUNT_NOT_REGISTERED     = 'This account is not registered'

    # Social Error
    MSG_SOCIAL_AUTHENTICATE_ERROR               = 'Authentication failed'

end
