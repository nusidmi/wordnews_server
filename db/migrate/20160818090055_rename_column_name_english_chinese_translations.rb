class RenameColumnNameEnglishChineseTranslations < ActiveRecord::Migration
  def change
    rename_column :english_chinese_translations, :english_vocabularies_id, :english_vocabulary_id
    rename_column :english_chinese_translations, :chinese_vocabularies_id, :chinese_vocabulary_id
  end

end
