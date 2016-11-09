class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :user_id
      t.integer :ann_id
      t.string :selected_text
      t.string :translation
      t.string :lang
      t.integer :paragraph_idx
      t.integer :text_idx
      t.string :url

      t.timestamps
    end
  end
end
