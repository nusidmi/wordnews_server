class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :categories
    drop_table :chinese_words
    drop_table :dictionaries
    drop_table :dictionary_words
    drop_table :difficulties
    drop_table :english_words
    drop_table :hard_coded_quizzes
    drop_table :hard_coded_words
    drop_table :histories
    drop_table :meanings
    drop_table :sentences
    drop_table :translates
    drop_table :understands
    drop_table :word_categories
  end
end
