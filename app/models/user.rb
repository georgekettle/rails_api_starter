class User < ApplicationRecord
  has_secure_password

  # Relationships
  has_many :sessions, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  # Validations
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  
  # Callbacks
  before_save :downcase_email

  # Instance methods
  def invalidate_all_sessions!
    sessions.update_all(active: false)
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
