class AddIndexToVoteHistory < ActiveRecord::Migration
  def change
    add_index :vote_histories, [:user_id, :pair_id, :source, :is_explicit], :name=>'vote_search_index'
  end
end
