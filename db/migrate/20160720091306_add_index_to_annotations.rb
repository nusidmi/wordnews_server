class AddIndexToAnnotations < ActiveRecord::Migration
  def change
    add_index :annotations, [:user_id, :url, :selected_text, :lang]
    add_index :annotations, :url
  end
end
