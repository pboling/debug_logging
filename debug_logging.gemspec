# Get the GEMFILE_VERSION without *require* "my_gem/version", for code coverage accuracy
# See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-825171399
load "lib/debug_logging/version.rb"
gem_version = DebugLogging::Version::VERSION
DebugLogging::Version.send(:remove_const, :VERSION)

Gem::Specification.new do |spec|
  spec.name = "debug_logging"
  spec.version = gem_version
  spec.authors = ["Peter Boling", "John Gillson", "guckin"]
  spec.email = ["peter.boling@gmail.com"]

  # See CONTRIBUTING.md
  spec.cert_chain = ["certs/pboling.pem"]
  spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $PROGRAM_NAME.end_with?("gem")

  spec.summary = "Drop-in debug logging useful when a call stack gets unruly"
  spec.description = '
Unobtrusive debug logging for Ruby.  NO LITTERING.
Automatically log selected methods and their arguments as they are called at runtime!
'
  spec.homepage = "https://github.com/pboling/debug_logging"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pboling/debug_logging/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/pboling/debug_logging/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/pboling/debug_logging/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/debug_logging/#{spec.version}"
  spec.metadata["wiki_uri"] = "https://github.com/pboling/debug_logging/wiki"
  spec.metadata["funding_uri"] = "https://liberapay.com/pboling"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir[
    "lib/**/*.rb",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md"
  ]
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  # Root Gemfile is only for local development only. It is not loaded on CI.
  # On CI we only need the gemspecs' dependencies (including development dependencies).
  # Exceptions, if any, will be found in gemfiles/*.gemfile

  spec.add_dependency("colorize", ">= 0")

  # Utilities
  spec.add_dependency("version_gem", "~> 1.1", ">= 1.1.4")
  spec.add_development_dependency("rake", ">= 13.2.1")

  # Optional
  spec.add_development_dependency("activesupport", ">= 5.2.4.4")

  # Code Coverage
  # CodeCov + GitHub setup is not via gems: https://github.com/marketplace/actions/codecov
  spec.add_development_dependency("kettle-soup-cover", "~> 1.0", ">= 1.0.2")

  # Documentation
  spec.add_development_dependency("kramdown", "~> 2.4")
  spec.add_development_dependency("yard", "~> 0.9", ">= 0.9.34")
  spec.add_development_dependency("yard-junk", "~> 0.0")

  # Linting
  spec.add_development_dependency("rubocop-lts", "~> 22.1", ">= 22.1.3")
  spec.add_development_dependency("rubocop-packaging", "~> 0.5", ">= 0.5.2")
  spec.add_development_dependency("rubocop-rspec", "~> 2.25")

  # Testing
  spec.add_development_dependency("rspec", ">= 3")
  spec.add_development_dependency("rspec-block_is_expected", "~> 1.0", ">= 1.0.5")
  spec.add_development_dependency("rspec_junit_formatter", "~> 0.6")
  spec.add_development_dependency("rspec-pending_for", ">= 0")
  spec.add_development_dependency("silent_stream", ">= 1")
end
