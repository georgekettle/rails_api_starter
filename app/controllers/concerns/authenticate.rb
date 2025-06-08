module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_request_info
  end

  private

  def authenticate_user!
    Current.user = nil
    Current.session = nil

    if (token = extract_token_from_header)
      begin
        authenticate_with_token(token)
      rescue Authentication::AuthenticationError => e
        render_error(
          message: e.message,
          code: 'invalid_token',
          status: :unauthorized
        )
        return
      end
    end

    unless Current.authenticated?
      render_error(
        message: 'You need to sign in or sign up before continuing.',
        code: 'unauthorized',
        status: :unauthorized
      )
    end
  end

  def authenticate_with_token(token)
    result = Authentication::AuthenticateToken.new(
      token: token,
      request_info: client_info
    ).call

    Current.user = result[:user]
    Current.session = result[:session]
  end

  def extract_token_from_header
    return nil unless request.headers['Authorization']&.start_with?('Token ')
    
    request.headers['Authorization'].split(' ').last
  end

  def set_request_info
    Current.request_id = request.request_id
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
  end

  # Helper methods to access Current attributes
  def current_user
    Current.user
  end

  def current_session
    Current.session
  end

  # Helper method to get client info
  def client_info
    {
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      request_id: request.request_id
    }
  end
end 