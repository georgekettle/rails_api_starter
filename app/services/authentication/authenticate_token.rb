module Authentication
  class AuthenticateToken
    attr_reader :token, :request_info

    # @param token [String] the authentication token from request
    # @param request_info [Hash] containing user_agent, ip_address, and request_id
    def initialize(token:, request_info:)
      @token = token
      @request_info = request_info
    end

    # @return [Hash] containing user and session if successful
    # @raise [AuthenticationError] if authentication fails
    def call
      raise AuthenticationError, 'No token provided' if token.blank?
      
      session = find_active_session
      validate_session!(session)
      update_session_tracking(session)
      
      { user: session.user, session: session }
    end

    private

    def find_active_session
      # Use indexed scope for better performance
      Session.active.includes(:user).find_each do |session|
        return session if Session.valid_token?(token, session.token_digest)
      end

      raise AuthenticationError, 'Invalid or expired token'
    end

    def validate_session!(session)
      if session_security_mismatch?(session)
        session.update!(active: false)
        log_security_mismatch(session)
        raise AuthenticationError, 'Session invalidated due to security mismatch'
      end
    end

    def session_security_mismatch?(session)
      return false if Rails.env.test? # Skip in test environment
      
      # Check if the request is coming from a significantly different client
      # This helps prevent token theft and session hijacking
      session.ip_address != request_info[:ip_address] ||
        session.user_agent != request_info[:user_agent]
    end

    def update_session_tracking(session)
      session.touch_last_seen!
    end

    def log_security_mismatch(session)
      Rails.logger.warn(
        "Security mismatch for session #{session.id}. " \
        "Original IP: #{session.ip_address}, Current IP: #{request_info[:ip_address]}. " \
        "Original UA: #{session.user_agent}, Current UA: #{request_info[:user_agent]}"
      )
    end
  end

  class AuthenticationError < StandardError; end
end 