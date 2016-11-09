class AddLangToLearningHistory < ActiveRecord::Migration
  def change
    add_column :learning_histories, :lang, :string
  end
end
