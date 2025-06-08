class PasswordResetToken < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Scopes
  scope :unused, -> { where(used_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :used, -> { where.not(used_at: nil) }

  # Callbacks
  before_validation :set_default_expiry, on: :create

  # Class methods
  def self.generate_unique_secure_token
    SecureRandom.base58(24)
  end

  def self.digest(token)
    BCrypt::Password.create(token)
  end

  def self.valid_token?(token, digest)
    BCrypt::Password.new(digest).is_password?(token)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  # Instance methods
  def valid_for_reset?
    !used? && !expired?
  end

  def used?
    used_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def mark_as_used!(ip_address = nil)
    update!(
      used_at: Time.current,
      used_ip_address: ip_address
    )
  end

  private

  def set_default_expiry
    self.expires_at ||= 1.hour.from_now
  end
end
