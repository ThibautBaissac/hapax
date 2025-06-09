RSpec.configure do |config|
  # Include Devise test helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Ensure Devise mappings and Warden are properly configured for testing
  config.before(:suite) do
    # Reload routes to ensure Devise mappings are initialized
    Rails.application.reload_routes!
    Warden.test_mode!
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
