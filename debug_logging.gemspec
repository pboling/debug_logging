# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debug_logging/version'

Gem::Specification.new do |spec|
  spec.name          = "debug_logging"
  spec.version       = DebugLogging::VERSION
  spec.authors       = ["Peter Boling"]
  spec.email         = ["peter.boling@gmail.com"]

  spec.summary       = %q{Drop-in debug logging useful when a call stack gets unruly}
  spec.description   = %q{Automatically log Class.method(arguments) as they are called at runtime!}
  spec.homepage      = "https://github.com/pboling/debug_logging"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "colorize", "~> 0.8"
  spec.add_development_dependency "rspec-pending_for"
  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
