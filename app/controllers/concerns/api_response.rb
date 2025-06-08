module ApiResponse
  extend ActiveSupport::Concern

  included do
    # Ensure this concern is included in controllers that inherit from Api::V1::BaseController
  end

  # Renders a successful API response
  # @param data [Object] The payload to return.
  # @param status [Symbol] The HTTP status code (e.g., :ok, :created).
  # @param pagination [Hash, nil] Optional hash for pagination details.
  def render_success(data:, status: :ok, pagination: nil)
    response = { data: data, error: nil }
    response[:pagination] = pagination if pagination.present?
    render json: response, status: status
  end

  # Renders an error API response
  # @param message [String] A human-readable error message.
  # @param code [String] A snake_case error code.
  # @param status [Symbol] The HTTP status code (e.g., :bad_request, :unauthorized, :not_found).
  # @param details [Hash, nil] Optional hash for more error context (e.g., validation errors).
  def render_error(message:, code:, status: :bad_request, details: nil)
    render json: {
      data: nil,
      error: {
        message: message,
        code: code,
        details: details
      }.compact # compact removes nil values from the hash
    }, status: status
  end
end 