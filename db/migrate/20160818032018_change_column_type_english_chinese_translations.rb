class ChangeColumnTypeEnglishChineseTranslations < ActiveRecord::Migration
  def up
    change_column :english_chinese_translations, :pos_tag, 'integer USING pos_tag::integer'
  end

  def down
    change_column :english_chinese_translations, :pos_tag, :string
  end
end
