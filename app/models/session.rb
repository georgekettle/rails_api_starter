class Session < ApplicationRecord
  belongs_to :user
  has_secure_token

  # Constants
  DEFAULT_EXPIRY = 30.days

  # Validations
  validates :expires_at, presence: true

  # Scopes
  scope :not_expired, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  # Callbacks
  before_validation :set_default_expiry, on: :create

  # Instance methods
  def expired?
    expires_at <= Time.current
  end

  def not_expired?
    !expired?
  end

  private

  def set_default_expiry
    self.expires_at ||= DEFAULT_EXPIRY.from_now
  end
end
