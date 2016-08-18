class DropUrlToAnnotation < ActiveRecord::Migration
  def change
    remove_column :annotations, :url
  end

end
