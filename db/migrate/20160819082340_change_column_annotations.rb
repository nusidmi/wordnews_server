class ChangeColumnAnnotations < ActiveRecord::Migration
  def change
    remove_column :annotations, :upvote, :downvote
    add_column :annotations, :vote, :integer, default: 0
  end
end
