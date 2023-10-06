# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debug_logging/version'

Gem::Specification.new do |spec|
  spec.name          = 'debug_logging'
  spec.version       = DebugLogging::VERSION
  spec.authors       = ['Peter Boling', 'guckin']
  spec.email         = ['peter.boling@gmail.com']

  spec.summary       = 'Drop-in debug logging useful when a call stack gets unruly'
  spec.description   = '
Unobtrusive debug logging for Ruby.  NO LITTERING.
Automatically log selected methods and their arguments as they are called at runtime!
'
  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/pboling/debug_logging'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.0' # Uses magic comments

  spec.add_runtime_dependency 'colorize', '>= 0'
  spec.add_development_dependency 'activesupport', '~> 7.1', '>= 5.2.4.4'
  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'byebug', '>= 11'
  spec.add_development_dependency 'rake', '>= 13'
  spec.add_development_dependency 'rspec', '>= 3'
  spec.add_development_dependency 'rspec-pending_for', '>= 0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-md'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
  spec.add_development_dependency 'silent_stream', '>= 1'
end
