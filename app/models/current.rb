class Current < ActiveSupport::CurrentAttributes
  # Attributes that are available throughout the request lifecycle
  attribute :user, :session, :request_id, :user_agent, :ip_address

  # Reset user-related information
  def user=(user)
    super
    self.session = nil if user.nil?
  end

  # Helper method to check if we have an authenticated user
  def self.authenticated?
    user.present?
  end

  # Helper method to get client info
  def client_info
    {
      user_agent: user_agent,
      ip_address: ip_address,
      request_id: request_id
    }
  end
end 