import argparse

import nltk
import pickle
import numpy

#from nltk.tokenize import sent_tokenize
#from nltk import word_tokenize

#nltk.data.path.append('nltk_data')
#nltk.data.path.append('../../public/MCQ Generation/nltk_data')
nltk.data.path.append('./public/MCQ Generation/nltk_data')


def sentence_segmenter(text):
    sent_tokenize_list = nltk.sent_tokenize(text)
    return sent_tokenize_list


def word_tokenizer(sentence):
    tokens = nltk.word_tokenize(sentence)
    return tokens
    

# Return format: [('word', 'tag'), ('word', 'tag'),...]
# NLTK uses Penn Treebank Tag Set
def pos_tagger(text):
    tokenized_text = nltk.word_tokenize(text)
    word_tags = nltk.pos_tag(tokenized_text)
    return word_tags
    
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('mode')
    parser.add_argument('text')

    args = parser.parse_args()
    try: 
        if args.mode=='sentence_segmenter':
            result = sentence_segmenter(args.text)
            print result
        elif args.mode=='word_tokenizer':
            result = word_tokenizer(args.text)
            print result
        elif args.mode=='pos_tagger':
            result = pos_tagger(args.text)
            print result
        
    except Exception as e:
        print 'ERROR'
        print e
    
