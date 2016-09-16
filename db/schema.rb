# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160913062326) do

  create_table "annotation_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "annotation_id"
    t.integer  "client_ann_id"
    t.string   "lang"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "annotations", :force => true do |t|
    t.string   "selected_text"
    t.string   "translation"
    t.string   "lang"
    t.integer  "paragraph_idx"
    t.integer  "text_idx"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "article_id"
    t.integer  "vote",          :default => 0
    t.integer  "implicit_vote", :default => 0, :null => false
  end

  add_index "annotations", ["article_id"], :name => "index_annotations_on_article_id"

  create_table "articles", :force => true do |t|
    t.string   "website"
    t.string   "url"
    t.string   "url_postfix"
    t.integer  "annotation_count"
    t.string   "lang"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "title"
    t.date     "publication_date"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "chinese_vocabularies", :force => true do |t|
    t.string   "text"
    t.string   "pronunciation"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "chinese_vocabularies", ["text"], :name => "index_chinese_vocabularies_on_text"

  create_table "chinese_words", :force => true do |t|
    t.string   "chinese_meaning"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "pronunciation"
  end

  create_table "dictionaries", :force => true do |t|
    t.string   "word_english"
    t.string   "word_chinese"
    t.string   "word_category"
    t.integer  "word_difficulty_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "word_id"
    t.string   "pronunciation"
    t.string   "property"
  end

  create_table "dictionary_words", :force => true do |t|
    t.integer  "chinese_words_id"
    t.integer  "english_words_id"
    t.string   "word_property"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "difficulties", :force => true do |t|
    t.integer  "word_difficulty_id"
    t.string   "word_difficulty_string"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "english_chinese_translations", :force => true do |t|
    t.integer  "chinese_vocabulary_id"
    t.integer  "english_vocabulary_id"
    t.integer  "pos_tag"
    t.integer  "frequency_rank"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "english_text"
    t.string   "chinese_text"
    t.string   "chinese_pronunciation"
  end

  add_index "english_chinese_translations", ["english_vocabulary_id", "chinese_vocabulary_id", "pos_tag"], :name => "pair_pos_index"

  create_table "english_vocabularies", :force => true do |t|
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "english_vocabularies", ["text"], :name => "index_english_vocabularies_on_text"

  create_table "english_words", :force => true do |t|
    t.string   "english_meaning"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "english_words", ["english_meaning"], :name => "english_meanings"

  create_table "example_sentences", :force => true do |t|
    t.string   "english_sentence"
    t.string   "chinese_sentence"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "hard_coded_quizzes", :force => true do |t|
    t.string   "url"
    t.string   "word"
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "quiz_type"
  end

  create_table "hard_coded_words", :force => true do |t|
    t.string   "url"
    t.string   "word"
    t.string   "translation"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "hard_coded_words", ["url"], :name => "hard_code_words_url"
  add_index "hard_coded_words", ["word"], :name => "hard_code_words_english"

  create_table "histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "meaning_id"
    t.integer  "frequency"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "histories", ["meaning_id"], :name => "histories_meaning"
  add_index "histories", ["user_id"], :name => "histories_user"

  create_table "learning_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "translation_pair_id"
    t.integer  "view_count"
    t.integer  "test_count"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "lang"
  end

  add_index "learning_histories", ["user_id", "lang", "test_count"], :name => "user_history_index"
  add_index "learning_histories", ["user_id", "translation_pair_id", "lang"], :name => "id_pair_lang_index"

  create_table "machine_translations", :force => true do |t|
    t.string   "text"
    t.string   "translation"
    t.string   "lang"
    t.string   "translator"
    t.integer  "article_id"
    t.integer  "paragraph_idx"
    t.integer  "text_idx"
    t.integer  "vote"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "implicit_vote", :default => 0, :null => false
  end

  create_table "meanings", :force => true do |t|
    t.integer  "chinese_words_id"
    t.integer  "english_words_id"
    t.string   "word_property"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "word_category_id"
  end

  add_index "meanings", ["english_words_id"], :name => "meaning_english_id"

  create_table "meanings_example_sentences", :force => true do |t|
    t.integer  "meaning_id"
    t.integer  "example_sentences_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "sentences", :force => true do |t|
    t.text     "english_sentence"
    t.text     "chinese_sentence"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "sentence_id"
    t.string   "word_english"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "transaction_code"
    t.string   "user_name"
    t.integer  "word_english"
    t.integer  "if_remembered"
    t.string   "url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "translates", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "understands", :force => true do |t|
    t.integer  "user_id"
    t.integer  "word_id"
    t.integer  "strength"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "if_understand"
    t.string   "url"
  end

  create_table "user_external_logins", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.string   "ext_auth_provider", :null => false
    t.string   "ext_user_id"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "login_name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "user_external_logins", ["ext_auth_provider", "ext_user_id"], :name => "index_user_external_logins_on_ext_auth_provider_and_ext_user_id"
  add_index "user_external_logins", ["user_id"], :name => "index_user_external_logins_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "user_name"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "email"
    t.string   "password_digest"
    t.integer  "public_key",                      :null => false
    t.integer  "score",            :default => 0, :null => false
    t.text     "avatar"
    t.integer  "role",             :default => 2, :null => false
    t.integer  "rank",             :default => 1, :null => false
    t.integer  "status",           :default => 1, :null => false
    t.integer  "learning_count",   :default => 0, :null => false
    t.integer  "annotation_count", :default => 0, :null => false
    t.datetime "registered_at"
    t.string   "remember_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "view_count",       :default => 0, :null => false
    t.integer  "quiz_count",       :default => 0, :null => false
    t.integer  "learnt_count",     :default => 0, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["public_key"], :name => "index_users_on_public_key"
  add_index "users", ["remember_digest"], :name => "index_users_on_remember_digest"

  create_table "vote_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "pair_id"
    t.integer  "vote",        :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "source"
    t.boolean  "is_explicit", :default => true, :null => false
  end

  add_index "vote_histories", ["user_id", "pair_id", "source", "is_explicit"], :name => "vote_search_index"

  create_table "word_categories", :force => true do |t|
    t.string   "category_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
