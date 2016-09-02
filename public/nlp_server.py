from flask import Flask
from flask import request
from flask import jsonify
import json
import nltk
import time
app = Flask(__name__)

from nltk.tokenize import sent_tokenize
from nltk import word_tokenize
from nltk.tokenize.treebank import TreebankWordTokenizer


nltk.data.path.append('./public/nltk_data')

sentence_segmenter = nltk.data.load('tokenizers/punkt/english.pickle')
word_tokenizer = TreebankWordTokenizer()
pos_tagger = nltk.data.load(nltk.tag._POS_TAGGER)


@app.route("/")
def index():
    return "index!"
    
    
def segment_sentence(text):
    text = text.replace("\n", " ")
    sent_tokenize_list = sentence_segmenter.tokenize(text)
    return sent_tokenize_list


def tokenize_words(sentence):
    tokens = nltk.word_tokenize(sentence)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    return tokens
    

# Return format: [('word', 'tag'), ('word', 'tag'),...]
# NLTK uses Penn Treebank Tag Set
def pos_tag(text):
    tokenized_text = word_tokenizer.tokenize(text)
    word_tags = pos_tagger(tokenized_text)
    return word_tags


def process_pipeline(text):
    start = time.time()
    result = []
    
    sentences = sentence_segmenter.tokenize(text)
    for sentence in sentences:
        tokenized_text = word_tokenizer.tokenize(sentence)
        word_tag_list = pos_tagger.tag(tokenized_text)
        
        words = []
        tags = []
        for word, tag in word_tag_list:
            words.append(word)
            tags.append(tag)
            
        rst_sent = {}
        rst_sent['sent'] = sentence
        rst_sent['words'] = ' '.join(words)
        rst_sent['tags'] = ' '.join(tags)
        result.append(rst_sent)
    
    end = time.time()
    print (end-start)
    return result
    
 
    
@app.route("/text_process", methods=['POST'])
def text_process():
  # for get
  #text = request.args.get('text', '')
  #mode = request.args.get('mode', '')
  
  content = request.json
  text = content['text']
  mode = content['mode']
  
  #print text
  #print mode
  
  if text=='' or mode=='':
     return "Invalid Parameters"
  
  result = '{}'
  if mode=='sentence_segmenter':
      result = sentence_segmenter(text)
  elif mode=='word_tokenizer':
      result = word_tokenizer(text)
  elif mode=='pos_tagger':
      result = pos_tagger(text)
  elif mode=='text_process_pipeline':
      result = process_pipeline(text)
        
        
  return jsonify(result)

if __name__ == "__main__":
    app.run()