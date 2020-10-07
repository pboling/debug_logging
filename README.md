# DebugLogging

Unobtrusive, inheritable-overridable-configurable, drop-in debug logging, that won't leave a mess behind when it is time to remove it.

| Project                 |  DebugLogging           |
|------------------------ | ----------------------- |
| gem name                |  [debug_logging](https://rubygems.org/gems/debug_logging) |
| compatibility           |  Ruby 2.4, 2.5, 2.6, 2.7 |
| license                 |  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT) |
| download rank           |  [![Downloads Today](https://img.shields.io/gem/rd/debug_logging.svg)](https://github.com/pboling/debug_logging) |
| version                 |  [![Version](https://img.shields.io/gem/v/debug_logging.svg)](https://rubygems.org/gems/debug_logging) |
| dependencies            |  [![Depfu](https://badges.depfu.com/badges/d1a4cf43255916521fef1e3685c61faa/count.svg)](https://depfu.com/github/pboling/debug_logging?project_id=2675) |
| continuous integration  |  [![Build Status](https://travis-ci.org/pboling/debug_logging.svg?branch=master)](https://travis-ci.org/pboling/debug_logging) |
| test coverage           |  [![Test Coverage](https://api.codeclimate.com/v1/badges/1f36d7019c3b81cae1a2/test_coverage)](https://codeclimate.com/github/pboling/debug_logging/test_coverage) |
| maintainability         |  [![Maintainability](https://api.codeclimate.com/v1/badges/1f36d7019c3b81cae1a2/maintainability)](https://codeclimate.com/github/pboling/debug_logging/maintainability) |
| code triage             |  [![Open Source Helpers](https://www.codetriage.com/pboling/debug_logging/badges/users.svg)](https://www.codetriage.com/pboling/debug_logging) |
| homepage                |  [on Github.com][homepage], [on Railsbling.com][blogpage] |
| documentation           |  [on RDoc.info][documentation] |
| live chat               |  [![Join the chat at https://gitter.im/pboling/debug_logging](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pboling/debug_logging?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |
| expert support          |  [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github) |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [🌏](https://about.me/peter.boling), [👼](https://angel.co/peter-boling), [:shipit:](http://coderwall.com/pboling), [![Tweet Peter](https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow)](http://twitter.com/galtzo), [🌹](https://nationalprogressiveparty.org) |

### Gives you (all are optional):

* *benchmarking*
* *colorization by class/method*
* *robust argument printer with customizable ellipsis*
* *unique invocation identifiers*
* *single line config, per class/instance/method config*
* *separate logger, if needed*
* *log method calls, also when exit scope*
* *Prevents heavy computation of strings with `logger.debug { 'log me' }` block format.*
* **so many free ponies** 🎠🐴🎠🐴🎠🐴

## Next Level Magic

Herein you will find:

* Classes inheriting from Module
* Zero tolerance policy on monkey patching
* 100% clean, 0% obtrusive
* 100% tested
* 100% Ruby 2.3+ compatible

NOTE: The manner this is made to work for class methods is totally different than the way this is made to work for instance methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'debug_logging'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debug_logging

## Usage

NOTE: Starting with version `1.0.12` this gem utilizes the `logger.debug { "block format" }` to avoid heavy debug processing when the log level threshold is set higher than the level of the statements produced as a result of the configuration of this gem.

Crack open the specs for more complex usage examples than the ones below.

### Without Rails

It just works. ;)
Configuration can go anywhere you want.  Configuration is the same regardless; see below.

### With Rails

Recommend creating `config/initializers/debug_logging.rb`, or adding to `config/application.rb` with:

```ruby
# Showing the defaults
DebugLogging.configuration.logger = Logger.new(STDOUT) # you probably want to override to be the Rails.logger, and if so you can't set it in the initializer, as it needs to be set after Rails.logger is set.
DebugLogging.configuration.log_level = :debug # at what level do the messages created by this gem sent at?
DebugLogging.configuration.multiple_last_hashes = false # pass every hash argument to last_hash_to_s_proc?
DebugLogging.configuration.last_hash_to_s_proc = nil # e.g. ->(hash) { "keys: #{hash.keys}" }
DebugLogging.configuration.last_hash_max_length = 1_000
DebugLogging.configuration.args_max_length = 1_000
DebugLogging.configuration.instance_benchmarks = false
DebugLogging.configuration.class_benchmarks = false
DebugLogging.configuration.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
DebugLogging.configuration.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
DebugLogging.configuration.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
DebugLogging.configuration.ellipsis = " ✂️ …".freeze
DebugLogging.configuration.mark_scope_exit = true # Only has an effect if benchmarking is off, since benchmarking always marks the scope exit
```

If you prefer to use the block style:

```ruby
DebugLogging.configure do |config|
  config.logger = Logger.new(STDOUT) # probably want to override to be the Rails.logger, and if so you can't set it in the initializer, as it needs to be set after Rails.logger is set.
  config.log_level = :debug # at what level do the messages created by this gem sent at?
  config.multiple_last_hashes = false # pass every hash argument to last_hash_to_s_proc?
  config.last_hash_to_s_proc = nil # e.g. ->(hash) { "keys: #{hash.keys}" }
  config.last_hash_max_length = 1_000
  config.args_max_length = 1_000
  config.instance_benchmarks = false
  config.class_benchmarks = false
  config.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
  config.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
  config.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
  config.ellipsis = " ✂️ …".freeze
  config.mark_scope_exit = true # Only has an effect if benchmarking is off, since benchmarking always marks the scope exit
end
```

**All** of the above **config** is **inheritable** and **configurable** at the **per-class** level as well!
Just prepend `debug_` to any config value you want to override in a class.

**All** of the above **config** is **inheritable** and **configurable** at the **per-instance** level as well!
Just prepend `debug_` to any config value you want to override on an instance of a class.

**All** of the above **config** is **inheritable** and **configurable** at the **per-method** level as well!
Just send along a hash of the config options when you call `logged` or `include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop], config: { ellipsis: " ✂️ 2 much" })`.  See the example class below, and the specs.

**NOTE ON** `Rails.logger` - It will probably be nil in your initializer, so setting the `config.logger` to `Rails.logger` there will result in setting it to `nil`, which means the default will end up being used: `Logger.new(STDOUT)`. Instead just config the logger in your application.rb, or anytime later, but *before your classes get loaded* and start inheriting the config:

```ruby
DebugLogging.configuration.logger = Rails.logger
```

Every time a method is called, get logs, optionally with arguments, a benchmarck, and a unique invocation identifier:

```ruby
class Car

  # adds the helper methods to the class, all are prefixed with debug_*,
  #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
  extend DebugLogging

  # per class configuration overrides!
  self.debug_class_benchmarks = true
  self.debug_instance_benchmarks = true

  # For instance methods:
  # Option 1: specify the exact method(s) to add logging to
  include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop])

  # Provides the `logged` method decorator
  extend DebugLogging::ClassLogger

  logged def make; new; end
  def design(*args); new; end
  def safety(*args); new; end
  def dealer_options(*args); new; end
  logged :design, :safety
  # override options for any instance method(s), by passing a hash as the last argument
  logged :dealer_options, { multiple_last_hashes: true }

  def drive(speed); speed; end
  def stop(**opts); 0; end

  # For instance methods:
  # Option 2: add logging to all instance methods defined above (but *not* defined below)
  include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))

  # override options for any instance method(s)
  include DebugLogging::InstanceLogger.new(i_methods: [:stop], config: { multiple_last_hashes: true })

  def will_not_be_logged; false; end

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/debug_logging.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
6. Create new Pull Request

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/).
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint](http://docs.rubygems.org/read/chapter/16#page74) with two digits of precision.

For example:

```ruby
spec.add_dependency 'debug_logging', '~> 2.0'
```

## License [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

MIT License

Copyright (c) 2017 - 2020 [Peter Boling][peterboling] of [RailsBling.com][railsbling]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[coderwall]: http://coderwall.com/pboling
[angellist]: https://angel.co/peter-boling
[documentation]: http://rdoc.info/github/pboling/debug_logging/frames
[homepage]: https://github.com/pboling/debug_logging
[blogpage]: http://www.railsbling.com/tags/debug_logging/
