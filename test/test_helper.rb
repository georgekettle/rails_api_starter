ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    
    # Authentication test helpers
    def auth_headers(user = nil)
      return {} unless user
      
      # Generate a unique token for each test
      token = Session.generate_unique_secure_token
      user.sessions.create!(
        token_digest: Session.digest(token),
        user_agent: 'Rails Testing',
        ip_address: '127.0.0.1'
      )
      
      { 'Authorization' => "Token #{token}" }
    end

    def json_response
      JSON.parse(response.body)
    end
  end
end
