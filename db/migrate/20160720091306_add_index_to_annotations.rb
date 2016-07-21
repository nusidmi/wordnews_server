class AddIndexToAnnotations < ActiveRecord::Migration
  def change
    add_index :annotations, [:user_id, :url]
    add_index :annotations, :url
  end
end
