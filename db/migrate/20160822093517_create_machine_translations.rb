class CreateMachineTranslations < ActiveRecord::Migration
  def change
    create_table :machine_translations do |t|
      t.string :text
      t.string :translation
      t.string :lang
      t.string :translator
      t.integer :article_id
      t.integer :paragraph_idx
      t.integer :text_idx
      t.integer :vote

      t.timestamps
    end
  end
end
