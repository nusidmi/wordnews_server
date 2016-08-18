class CreateEnglishChineseTranslations < ActiveRecord::Migration
  def change
    create_table :english_chinese_translations do |t|
      t.belongs_to :chinese_vocabularies
      t.belongs_to :english_vocabularies
      t.string :pos_tag
      t.integer :frequency_rank

      t.timestamps
    end
  end
end
