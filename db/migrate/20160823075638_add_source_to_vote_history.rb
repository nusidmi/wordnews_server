class AddSourceToVoteHistory < ActiveRecord::Migration
  def change
    add_column :vote_histories, :source, :integer
    rename_column :vote_histories, :annotation_id, :pair_id
  end
end
