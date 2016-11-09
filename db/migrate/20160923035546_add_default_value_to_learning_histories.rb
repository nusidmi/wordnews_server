class AddDefaultValueToLearningHistories < ActiveRecord::Migration
  def change
    change_column :learning_histories, :view_count, :integer, default:0, null:false
    change_column :learning_histories, :test_count, :integer, default:0, null:false
  end
end
