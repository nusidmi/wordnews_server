class CreateChineseAnnotationVocabularies < ActiveRecord::Migration
  def change
    create_table :chinese_annotation_vocabularies do |t|
      t.string :text
      t.string :pronunciation

      t.timestamps
    end
  end
end
