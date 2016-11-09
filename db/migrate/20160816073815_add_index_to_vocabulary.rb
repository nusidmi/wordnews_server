class AddIndexToVocabulary < ActiveRecord::Migration
  def change
    add_index :english_vocabularies, :text
    add_index :chinese_vocabularies, :text
    add_index :english_chinese_translations, [:english_vocabularies_id, :chinese_vocabularies_id, :pos_tag], :name => 'pair_pos_index'
  end
end
