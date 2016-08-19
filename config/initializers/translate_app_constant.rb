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

POS_INDEX                               = {'NN'=>1, 'VB'=>2, 'RB'=>4, 'JJ'=>5}
ANNOTATION_COUNT_MAX                    = 5.freeze