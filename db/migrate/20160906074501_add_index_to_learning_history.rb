class AddIndexToLearningHistory < ActiveRecord::Migration
  def change
    add_index :learning_histories, [:user_id, :lang, :test_count], :name=>'user_history_index'
  end
end
