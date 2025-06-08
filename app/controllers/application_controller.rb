class ApplicationController < ActionController::API
  # Since we're using API mode, we don't need CSRF protection
  # and we don't need to skip it in the BaseController
end
