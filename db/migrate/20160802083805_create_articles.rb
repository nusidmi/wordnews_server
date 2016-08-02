class CreateArticles < ActiveRecord::Migration
  def change
    create_table :article do |t|
      t.string :website
      t.string :url
      t.string :url_postfix
      t.integer :annotation_count
      t.string :language

      t.timestamps
    end
  end
end
