class CreateUserExternalLogin < ActiveRecord::Migration
  def change
    create_table :user_external_logins do |t|
      t.integer   :user_id, null: false
      t.string    :ext_auth_provider, null: false
      t.string    :ext_user_id
      t.string    :name
      t.string    :first_name
      t.string    :last_name
      t.string    :email
      t.string    :login_name
      t.string    :oauth_token
      t.datetime  :oauth_expires_at
      t.timestamps
    end

    add_index(:user_external_logins, [:ext_auth_provider, :ext_user_id])
    add_index(:user_external_logins, :user_id)

  end

end
