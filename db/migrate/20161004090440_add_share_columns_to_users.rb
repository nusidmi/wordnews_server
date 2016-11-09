class AddShareColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_share_count, :integer, default:0
  end
end
