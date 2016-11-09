class AddColumnToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :upvote, :integer, default: 0
    add_column :annotations, :downvote, :integer, default: 0
  end
end
