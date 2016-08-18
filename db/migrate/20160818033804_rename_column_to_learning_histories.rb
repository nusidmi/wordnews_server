class RenameColumnToLearningHistories < ActiveRecord::Migration
  def change
    rename_column :learning_histories, :meaning_id, :translation_pair_id
  end

end
