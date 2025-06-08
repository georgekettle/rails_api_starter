module Authentication
  class AuthenticateUser
    include ActiveModel::Validations

    attr_reader :email, :password, :request_info

    validates :email, :password, presence: true

    # @param email [String] user's email
    # @param password [String] user's password
    # @param request_info [Hash] containing user_agent, ip_address, and request_id
    def initialize(email:, password:, request_info:)
      @email = email&.downcase
      @password = password
      @request_info = request_info
    end

    # @return [Hash] containing user and token if successful
    # @raise [ValidationError] if validation fails
    # @raise [AuthenticationError] if authentication fails
    def call
      raise ValidationError, errors unless valid?
      
      user = find_and_authenticate_user
      token = create_session_for_user(user)
      
      { user: user, token: token }
    end

    private

    def find_and_authenticate_user
      user = User.find_by(email: email)
      
      unless user&.authenticate(password)
        log_failed_attempt
        raise AuthenticationError, 'Invalid email or password'
      end

      user
    end

    def create_session_for_user(user)
      token = Session.generate_unique_secure_token
      
      user.sessions.create!(
        token_digest: Session.digest(token),
        user_agent: request_info[:user_agent],
        ip_address: request_info[:ip_address],
        last_seen_at: Time.current
      )

      token
    end

    def log_failed_attempt
      Rails.logger.info(
        "Failed login attempt for email: #{email}, " \
        "IP: #{request_info[:ip_address]}, " \
        "UA: #{request_info[:user_agent]}"
      )
    end
  end

  class AuthenticationError < StandardError; end
  class ValidationError < StandardError
    def initialize(errors)
      super(errors.full_messages.to_sentence)
    end
  end
end 