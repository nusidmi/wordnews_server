class AddArticleIdToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :article_id, :integer
    add_index :annotations, :article_id
  end
end
