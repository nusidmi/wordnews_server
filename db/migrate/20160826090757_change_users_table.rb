class ChangeUsersTable < ActiveRecord::Migration
  def up
    remove_column :users, :if_translate
    remove_column :users, :translate_categories

    add_column :users, :email, :string
    add_column :users, :password_digest, :string
    add_column :users, :public_key, :integer
    add_column :users, :fb_id, :string
    add_column :users, :gp_id, :string
    add_column :users, :twitter_id, :string
    add_column :users, :score, :integer, default: 0, null: false
    add_column :users, :avatar, :text
    add_column :users, :role, :integer, default: 2, null: false
    add_column :users, :rank, :integer, default: 1, null: false
    add_column :users, :status, :integer, default: 1, null: false
    add_column :users, :trans_count, :integer, default: 0, null: false
    add_column :users, :anno_count, :integer, default: 0, null: false
    add_column :users, :registered_at, :datetime
    add_column :users, :remember_digest, :string

    add_index :users, :public_key
    add_index :users, :email
    add_index :users, :remember_digest

    User.find_each do |user|
      counter = 0
      begin
        user.public_key = rand(10000..2000000000)
        if user.save
          break;
        end
        counter+=1
      end while counter < 5
    end
  end


  def down
  end
end
