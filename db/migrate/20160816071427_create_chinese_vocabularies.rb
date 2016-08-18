class CreateChineseVocabularies < ActiveRecord::Migration
  def change
    create_table :chinese_vocabularies do |t|
      t.string :text
      t.string :pronunciation

      t.timestamps
    end
  end
end
