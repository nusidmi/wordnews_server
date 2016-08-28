class User < ActiveRecord::Base
  attr_accessor :remember_token

  attr_accessible :user_name, :email, :password_digest, :public_key, :fb_id, :gp_id, :twitter_id, :score, :avatar, :role, :rank, :status, :trans_count, :anno_count
  validates :user_name, length: { maximum: 255 }

  validates :email, length: { maximum: 255 }
  validates :public_key, uniqueness: true
  has_many :histories, :dependent => :destroy

  # Returns the hash digest of the given string.
  def self.digest(string)
    BCrypt::Password.create(string)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    if remember_digest.nil?
      return false
    else
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
