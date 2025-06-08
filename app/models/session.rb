class Session < ApplicationRecord
  belongs_to :user

  # Constants
  TOKEN_LENGTH = 32
  DEFAULT_EXPIRY = 30.days
  ROTATION_THRESHOLD = 7.days
  INACTIVE_THRESHOLD = 24.hours
  CLEANUP_PROBABILITY = 0.1 # 10% chance of cleanup on each request

  # Validations
  validates :token_digest, presence: true, uniqueness: true
  validates :last_seen_at, presence: true
  validates :expires_at, presence: true

  # Scopes
  scope :active, -> { 
    cleanup_expired if should_cleanup?
    where(active: true).where('expires_at > ?', Time.current) 
  }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :inactive, -> { where(active: false) }
  scope :stale, -> { where('last_seen_at < ?', INACTIVE_THRESHOLD.ago) }
  scope :needs_rotation, -> { active.where('created_at < ?', ROTATION_THRESHOLD.ago) }

  # Callbacks
  before_validation :set_default_expiry, on: :create
  before_validation :set_last_seen_at, on: :create

  # Class methods
  def self.generate_unique_secure_token
    SecureRandom.urlsafe_base64(TOKEN_LENGTH)
  end

  def self.digest(token)
    BCrypt::Password.create(token, cost: bcrypt_cost)
  end

  def self.valid_token?(token, digest)
    BCrypt::Password.new(digest).is_password?(token)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def self.cleanup_expired
    transaction do
      expired.or(stale).find_each(&:invalidate!)
    end
  end

  def self.bcrypt_cost
    Rails.env.test? ? BCrypt::Engine::MIN_COST : BCrypt::Engine::DEFAULT_COST
  end

  def self.should_cleanup?
    rand < CLEANUP_PROBABILITY
  end

  # Instance methods
  def expired?
    expires_at <= Time.current
  end

  def active?
    active && !expired?
  end

  def needs_rotation?
    created_at < ROTATION_THRESHOLD.ago
  end

  def stale?
    last_seen_at < INACTIVE_THRESHOLD.ago
  end

  def touch_last_seen!
    update_column(:last_seen_at, Time.current)
  end

  def invalidate!
    update_column(:active, false)
  end

  def rotate!
    return false unless active?

    transaction do
      invalidate!
      new_token = self.class.generate_unique_secure_token
      new_session = user.sessions.create!(
        token_digest: self.class.digest(new_token),
        user_agent: user_agent,
        ip_address: ip_address,
        last_seen_at: Time.current
      )
      
      { token: new_token, session: new_session }
    end
  end

  private

  def set_default_expiry
    self.expires_at ||= DEFAULT_EXPIRY.from_now
  end

  def set_last_seen_at
    self.last_seen_at ||= Time.current
  end
end
