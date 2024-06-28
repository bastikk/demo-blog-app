class ApplicationController < ActionController::Base
  # Your existing code...

  def current_user
    # Mocking current_user for demonstration. Replace with your actual authentication method.
    User.first
  end
end
