class RemoveColumnToAnnotations < ActiveRecord::Migration
  def change
    remove_column :annotations, :ann_id, :user_id
  end

end
