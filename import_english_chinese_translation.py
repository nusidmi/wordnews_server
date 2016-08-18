#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Use this script to populate the database with the csv file specified in the program.
    Note that this script does not create the tables ... since the database was inherited from the existing app
    create them first, if needed
    After this is run, there is still a need to fill in the pinyin. The other script in the same repo, add_pinyin.py
    can be used as a starting point.
"""

import os
import csv
import psycopg2
import urlparse
#import nltk
import pprint
#import sqlite3

urlparse.uses_netloc.append("postgres")


def get_pos_index(pos_tag):
    category = 1  # noun
    if pos_tag == 'verb':
        category = 2
    elif pos_tag == 'preposition':
        category = 3
    elif pos_tag == 'adverb':
        category = 4
    elif pos_tag == 'adjective':
        category = 5
    elif pos_tag == 'prounoun':
        category = 6
    elif pos_tag == 'conjunction':
        category = 7
    return category
    
    
database_to_use = 'postgres'
if (database_to_use == 'postgres'):
# obtain the details of the database and fill in here
# on heroku, this can be found by clicking on the database used
# from the app's page
    conn = psycopg2.connect(
        database="translate_db_development",
        user="zhaoyue",
        password="fypzhaoyue",
        host="localhost",
        port=5432
    )

cursor = conn.cursor()

rows_inserted = 0
rows_to_start_inserting = 0

with open('dictionary.csv', 'rb') as csvfile:

    reader = csv.reader(csvfile, delimiter=',')

    prev_word = None
    english_word_id = None
    prev_pos = None
    count = 0
    for row in reader:
        try:
            english_word, chinese_word, pos_tag = row
        except ValueError as e:
            print e
            print row

        english_word = english_word.lower()
        #print english_word
        

        if english_word != prev_word:
            conn.commit()
            count = 0
            prev_pos = None

            # first tuple of the word
            cursor.execute("SELECT id FROM english_vocabularies WHERE text=%s", (english_word,))

            result = cursor.fetchone()
            if result is None or len(result) == 0:
                print english_word + ' is not found'
            english_word_id = result[0]
        else:
            if pos_tag == prev_pos:
                count += 1
            else:
                count = 0
                

        cursor.execute("SELECT id FROM chinese_vocabularies WHERE text=%s", (chinese_word,))
        result = cursor.fetchone()
        if result is None or len(result) == 0:
            print chinese_word + ' is not found'
        chinese_word_id = result[0]
        
        
        sql = "INSERT INTO english_chinese_translations (id, chinese_vocabularies_id, english_vocabularies_id, pos_tag, frequency_rank, created_at, updated_at) " + \
              "VALUES(nextval('english_chinese_translations_id_seq'), %s, %s, %s, %s, current_timestamp, current_timestamp)"
        category = get_pos_index(pos_tag)
        cursor.execute(sql, (chinese_word_id, english_word_id, category, count,))
        

        prev_word = english_word
        prev_pos = pos_tag
    conn.commit()
