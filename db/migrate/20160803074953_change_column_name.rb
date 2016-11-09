class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :articles, :language, :lang
  end
end
