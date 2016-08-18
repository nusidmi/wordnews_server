class CreateEnglishVocabularies < ActiveRecord::Migration
  def change
    create_table :english_vocabularies do |t|
      t.string :text

      t.timestamps
    end
  end
end
