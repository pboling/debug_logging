require "bundler/setup"
require "rspec/pending_for"
require "active_support/testing/stream"

begin
  require "byebug" if RbConfig::CONFIG["RUBY_INSTALL_NAME"] == "ruby"
rescue LoadError
  puts "Failed to load gem byebug"
end

# NOTE: Switching coveralls to simplecov causing many spec failures.
#       Something about coveralls bleeds into this gem, and this gem is
#       dependent on that tweaking behavior
begin
  require "coveralls"
  Coveralls.wear!
rescue LoadError
  # If coveralls fails to load, many specs will fail.
  # I need to figure out what this isssue is!
  puts "Failed to load gem coveralls"
end

# This gem!
require "debug_logging"
require "support/shared_context"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.include ActiveSupport::Testing::Stream

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
