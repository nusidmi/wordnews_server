class ChangeUserPublicKeyNonNull < ActiveRecord::Migration
  def up
    change_column_null :users, :public_key, false
  end
end
