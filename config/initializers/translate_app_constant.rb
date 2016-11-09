# Define constant that is used through out the project

NUM_OF_WORDS_TO_TRANSLATE_DEFAULT       = 2.freeze
NUM_OF_WORDS_TO_TRANSLATE_MIN           = 1.freeze
NUM_OF_WORDS_TO_TRANSLATE_MAX           = 10.freeze

QUIZ_FREQUENCY_COUNT_MIN                = 4.freeze
QUIZ_FREQUENCY_COUNT_MAX                = 5.freeze 

# Give quiz to user after viewing the word for X times
VIEW_COUNT_MAX                          = 1.freeze 
# Skip the word to learn since the user knows it well
QUIZ_COUNT_MAX                          = 3.freeze


MAX_USER_CREATE_RETRIES                 = 5.freeze

USER_ID_CREATE_MIN                      = 10000.freeze
USER_ID_CREATE_MAX                      = 2000000000.freeze
USER_START_SCORE                        = 0.freeze

USER_ROLE_ADMIN                         = 1.freeze
USER_ROLE_LEARNER                       = 2.freeze
USER_ROLE_ANNOTATOR                     = 3.freeze

USER_START_RANK                         = 1.freeze

USER_STATUS_NOT_BLOCKED                 = 1.freeze
USER_STATUS_BLOCKED                     = 0.freeze

USER_START_TRANSLATE_COUNT              = 0.freeze
USER_START_ANNOTATION_COUNT             = 0.freeze
USER_START_VOTE_COUNT                   = 0.freeze

USER_NAME_MAX_LENGTH                    = 255.freeze
USER_EMAIL_MAX_LENGTH                   = 255.freeze

WEIGHT_HUMAN_ANNOTATION                 = 0.5.freeze # used to weight the overall votes
WEIGHT_IMPLICIT_VOTE                    = 0.1.freeze

MAX_FB_SHARE_WITH_CREDITS               = 1


POS_INDEX                               = {'NN'=>1, 'VB'=>2, 'RB'=>4, 'JJ'=>5}
ANNOTATION_COUNT_MAX                    = 5.freeze
TRANSLATION_SOURCE                      = {'machine'=>0, 'human'=>1}

NLP_HOST                                =  (ENV["NLP_HOST"].present?)? ENV["NLP_HOST"]: 'http://wordnews-nlp.herokuapp.com'
QUIZ_HOST                               =  (ENV["QUIZ_HOST"].present?)? ENV["QUIZ_HOST"]: 'http://wordnews-nlp.herokuapp.com'

CHINESE_AUDIO_HOST                      = 'http://www.chinese-tools.com/jdd/public/ct/pinyinaudio'
CHINESE_MORE_HOST                       = 'http://www.youdao.com/w/eng'
IMS_HOST                                = (ENV["IMS_HOST"].present?)? ENV["IMS_HOST"]: 'http://ims-translator.herokuapp.com'

FACEBOOK_KEY                            = (ENV["FACEBOOK_KEY"].present?)? ENV["FACEBOOK_KEY"]: '1005339512908612'
