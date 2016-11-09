class CreateLearningHistories < ActiveRecord::Migration
  def change
    create_table :learning_histories do |t|
      t.integer :user_id
      t.integer :meanings_id
      t.integer :view_count
      t.integer :test_count

      t.timestamps
    end
  end
end
