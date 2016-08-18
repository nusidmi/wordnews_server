class ChangeColumnNameToLearningHistory < ActiveRecord::Migration
  def change
    rename_column :learning_histories, :meanings_id, :meaning_id
  end
end
