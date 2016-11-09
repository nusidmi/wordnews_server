class AddIdLangPairIndexToLearningHistory < ActiveRecord::Migration
  def change
    add_index :learning_histories, [:user_id, :translation_pair_id, :lang], :name=>'id_pair_lang_index'
  end
end
