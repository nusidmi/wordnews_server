class AddColunmsToEnglishChineseTranslations < ActiveRecord::Migration
  def change
    add_column :english_chinese_translations, :english_text, :string
    add_column :english_chinese_translations, :chinese_text, :string
    add_column :english_chinese_translations, :chinese_pronunciation, :string
  end
end
