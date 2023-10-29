# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/pending_for'
require 'silent_stream'

begin
  require 'byebug' if RbConfig::CONFIG['RUBY_INSTALL_NAME'] == 'ruby'
rescue LoadError
  puts 'Failed to load gem byebug'
end

# This gem!
require 'debug_logging'
require 'support/shared_context'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.include SilentStream

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
