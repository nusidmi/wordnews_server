class AddColumnToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :title, :string
    add_column :articles, :publication_date, :date
  end
end
