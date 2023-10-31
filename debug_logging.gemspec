# frozen_string_literal: true

# Get the GEMFILE_VERSION without *require* "my_gem/version", for code coverage accuracy
# See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-825171399
load "lib/debug_logging/version.rb"
gem_version = DebugLogging::Version::VERSION
DebugLogging::Version.send(:remove_const, :VERSION)

Gem::Specification.new do |spec|
  spec.name = "debug_logging"
  spec.version = gem_version
  spec.authors = ["Peter Boling", "John ", "guckin"]
  spec.email = ["peter.boling@gmail.com"]

  spec.summary = "Drop-in debug logging useful when a call stack gets unruly"
  spec.description = '
Unobtrusive debug logging for Ruby.  NO LITTERING.
Automatically log selected methods and their arguments as they are called at runtime!
'
  spec.license = "MIT"
  spec.homepage = "https://github.com/pboling/debug_logging"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.4", "< 3"

  spec.add_runtime_dependency("colorize", ">= 0")

  # Optional
  spec.add_development_dependency("activesupport", ">= 5.2.4.4")

  # Debugging
  spec.add_development_dependency("byebug", ">= 11")

  # Utilities
  spec.add_development_dependency("rake", ">= 13")

  # Code Coverage
  # CodeCov + GitHub setup is not via gems: https://github.com/marketplace/actions/codecov
  spec.add_development_dependency("kettle-soup-cover", "~> 1.0", ">= 1.0.2")

  # Documentation
  spec.add_development_dependency("kramdown", "~> 2.4")
  spec.add_development_dependency("yard", "~> 0.9", ">= 0.9.34")
  spec.add_development_dependency("yard-junk", "~> 0.0")

  # Linting
  spec.add_development_dependency("rubocop-lts", "~> 12.1", ">= 12.1.1")
  spec.add_development_dependency("rubocop-packaging", "~> 0.5", ">= 0.5.2")
  spec.add_development_dependency("rubocop-rspec", "~> 2.25")

  # Testing
  spec.add_development_dependency("rspec", ">= 3")
  spec.add_development_dependency("rspec-block_is_expected", "~> 1.0", ">= 1.0.5")
  spec.add_development_dependency("rspec-pending_for", ">= 0")
  spec.add_development_dependency("rspec_junit_formatter", "~> 0.6")
  spec.add_development_dependency("silent_stream", ">= 1")
end
