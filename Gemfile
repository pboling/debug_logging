# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  # NOTE: Switching coveralls to simplecov causing many spec failures.
  #       Something about coveralls bleeds into this gem, and this gem is
  #       dependent on that tweaking behavior
  gem 'coveralls', '~> 0', require: false
end

# Specify your gem's dependencies in debug_logging.gemspec
gemspec
