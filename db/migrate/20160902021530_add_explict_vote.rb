class AddExplictVote < ActiveRecord::Migration
  def change
    add_column :annotations, :implicit_vote, :integer, default: 0, null: false
    add_column :machine_translations, :implicit_vote, :integer, default:0, null: false
    add_column :vote_histories, :is_explicit, :boolean, default:true, null: false
  end
end
