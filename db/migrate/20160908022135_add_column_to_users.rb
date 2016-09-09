class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :view_count, :integer, default:0, null: false
    add_column :users, :quiz_count, :integer, default:0, null: false
    add_column :users, :learnt_count, :integer, default:0, null: false
    rename_column :users, :trans_count, :learning_count
    rename_column :users, :anno_count, :annotation_count
  end
end
