class User < ActiveRecord::Base
  attr_accessor :remember_token, :reset_token

  attr_accessible :user_name, :email, :avatar, :status, 
                  :password_digest, :public_key, :fb_id, :gp_id, :twitter_id, 
                  :role, :score, :rank,
                  :view_count, :quiz_count, :learning_count, :learnt_count, 
                  :annotation_count
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

  def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

end
