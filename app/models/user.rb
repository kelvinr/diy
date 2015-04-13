class User < ActiveRecord::Base
  attr_accessor :remember_token, :verification_token, :reset_token

  before_save :downcase_email
  before_save :set_avatar
  before_create :create_verification_digest
  before_create :set_default_subs

  validates :username, presence: true, length: {in: 3..50}, uniqueness:
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                              format: {with: EMAIL_REGEX},
                      uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, length: {minimum: 5}, allow_blank: true

  has_many :comments
  has_many :questions

  has_many :user_categories
  has_many :subs, through: :user_categories, source: :category

  has_many :recieved_messages, class_name: :Message, foreign_key: :recipient_id
  has_many :sent_messages, class_name: :Message, foreign_key: :sender_id

  has_many :unread_messages, -> (obj) {where('read is false')}, class_name: :Message, foreign_key: :recipient_id

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update(remember_digest: User.digest(remember_token))
  end

  def forget
    update(remember_digest: nil)
    @current_user = nil
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def verify
    update(verified: true)
    update(verified_at: Time.zone.now)
  end

  def send_verification_email
    UserMailer.email_verification(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update(reset_digest: User.digest(reset_token))
    update(reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def mark_unread_messages!
    unread_messages.each do |msg|
      msg.mark_read!
    end

    self.unread_messages.clear
  end

  def delete_avatar
    key = self.avatar_url.match(/[^"]+/, 35).to_s
    unless key.empty? || self.avatar_url.include?('avatar-placeholder.png')
      obj = S3_BUCKET.object(key)
      obj.delete if obj.exists?
    end
  end

  def set_avatar
    self.avatar_url = 'https://s3.amazonaws.com/diyavatar/avatar-placeholder.png' if self.avatar_url.blank?
  end

  private

    def set_default_subs
      self.subs << Category.where(id: [1, 2, 3])
    end

    def downcase_email
      self.email = email.downcase
    end

    def create_verification_digest
      self.verification_token = User.new_token
      self.verification_digest = User.digest(verification_token)
    end
end
