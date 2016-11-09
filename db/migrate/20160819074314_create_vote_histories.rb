class CreateVoteHistories < ActiveRecord::Migration
  def change
    create_table :vote_histories do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.integer :vote, default: 0

      t.timestamps
    end
  end
end
