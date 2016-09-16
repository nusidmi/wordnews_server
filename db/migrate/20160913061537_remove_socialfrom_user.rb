class RemoveSocialfromUser < ActiveRecord::Migration
  def change
    remove_column :users, :fb_id
    remove_column :users, :gp_id
    remove_column :users, :twitter_id
  end
end
