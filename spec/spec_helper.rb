require "bundler/setup"
require "rspec/pending_for"
require "byebug" if RbConfig::CONFIG["RUBY_INSTALL_NAME"] == "ruby"
require "coveralls"
Coveralls.wear!

# This gem!
require "debug_logging"
require "support/shared_context"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
