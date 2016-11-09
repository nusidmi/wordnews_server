class UserExternalLogin < ActiveRecord::Base
  attr_accessible :user_id, :ext_auth_provider, :ext_user_id , :name,
                  :first_name, :last_name, :login_name,
                  :email, :oauth_token, :oauth_expires_at

  def self.create_with_omniauth(auth)
    where(auth.slice(:ext_auth_provider_id, :ext_user_id)).first_or_initialize.tap do |userextlogin|
      userextlogin.ext_auth_provider = auth.provider
      userextlogin.ext_user_id = auth.uid
      userextlogin.name = auth.info.name
      userextlogin.oauth_token = auth.credentials.token
      userextlogin.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
  end

  def self.find_with_omniauth(auth)
    where(ext_user_id: auth.uid, ext_auth_provider: auth.provider ).first
  end

  def self.find_with_user_id_and_provider(user_id, provider)
    where(user_id: user_id, ext_auth_provider: provider ).first
  end

end