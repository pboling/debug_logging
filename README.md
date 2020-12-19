# DebugLogging

Unobtrusive, inheritable-overridable-configurable, drop-in debug logging, that won't leave a mess behind when it is time to remove it.
Supports ActiveSupport::Notifications (thanks [@jgillson](https://github.com/jgillson)).  Optional ActiveRecord callback-style hooks that you can decorate your methods with. Hooks logic was taken from the [`slippy_method_hooks` gem](https://github.com/guckin/slippy_method_hooks), (thanks [@guckin](https://github.com/guckin)), and prefaced with `debug_` for this implementation. `DebugLogging::Finalize` is lightly modified from [this stackoverflow answer](https://stackoverflow.com/a/34559282).

## What do I mean by "unobtrusive"?

**Ugly** debug logging is added inside the body of a method, so it runs when a method is called. This can create a mess of your git history, and can even introduce new bugs to your code.

**Unobtrusive** debug logging stays out of the method, changes no logic, can't break your code, and yet it still runs when your method is called, and tells you everything you wanted to know. It doesn't mess with the git history of the method at all!

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
* *simple single line global config, or per class/instance/method config*
* *separate loggers, if needed*
* *log method calls, also when exit scope*
* *Prevents heavy computation of strings with `logger.debug { 'log me' }` block format, since v1.0.12*
* *ActiveSupport::Notifications integration for instrumenting/logging events on class and instance methods, since v3.1.3*
* *Optional instance, and class-instance, variable logging, since v3.1.3*
* *ActiveRecord style callback-hooks (optional: `require 'debug_logging/hooks'` and `include DebugLogging::Hooks`), since v3.1.3*
* *All configuration is inheritable to, and overridable by, child classes, since v3.1.3*
* *[Class finalization hook](https://stackoverflow.com/a/34559282) (optional: `require 'debug_logging/finalize'` and `extend DebugLogging::Finalize`), since v3.1.3*
* *Error handling hooks you can use to log problems when they happen, since v3.1.7*
* **so many free ponies** 🎠🐴🎠🐴🎠🐴

## Next Level Magic

Herein you will find:

* Classes inheriting from Module
* Zero tolerance policy on monkey patching
  * When the gem is loaded there are no monkey patches.
  * Rather, your own classes/methods get "patched" and "hooked" as you configure them.
* 100% clean, 0% obtrusive
* ~100% tested
* 100% Ruby 2.1+ compatible
  - use version `gem "debug_logging", "~> 1.0"` for Ruby < 2.3
  - use version `gem "debug_logging", "~> 2.0"` for Ruby 2.3
  - use version `gem "debug_logging", "~> 3.0"` for Ruby 2.4+

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

Crack open the specs for more complex usage examples than the ones below.

### Without Rails

It just works. ;)
Configuration can go anywhere you want.  Configuration is the same regardless; see below.

### With Rails

Recommend creating `config/initializers/debug_logging.rb`, or adding to `config/application.rb` with:

```ruby
# Showing the defaults
DebugLogging.configuration.logger = Logger.new($stdout) # you probably want to override to be the Rails.logger, and if so you can't set it in the initializer, as it needs to be set after Rails.logger is set.
DebugLogging.configuration.log_level = :debug # at what level do the messages created by this gem sent at?
DebugLogging.configuration.multiple_last_hashes = false # pass every hash argument to last_hash_to_s_proc?
DebugLogging.configuration.last_hash_to_s_proc = nil # e.g. ->(hash) { "keys: #{hash.keys}" }
DebugLogging.configuration.last_hash_max_length = 1_000
DebugLogging.configuration.args_to_s_proc = nil # e.g. ->(record) { "record id: #{record.id}" }
DebugLogging.configuration.args_max_length = 1_000
DebugLogging.configuration.instance_benchmarks = false
DebugLogging.configuration.class_benchmarks = false
DebugLogging.configuration.active_support_notifications = false
DebugLogging.configuration.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
DebugLogging.configuration.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
DebugLogging.configuration.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
DebugLogging.configuration.ellipsis = ' ✂️ …'.freeze
DebugLogging.configuration.mark_scope_exit = true # Only has an effect if benchmarking is off, since benchmarking always marks the scope exit
DebugLogging.configuration.add_payload = false # or a proc which will be called to print the payload
DebugLogging.configuration.payload_max_length = 1000
DebugLogging.configuration.error_handler_proc = nil # e.g. ->(error, config, obj, method_name, args) { config.log { "#{error.class}: #{error.message} in #{method_name}\nargs: #{args.inspect}" } }
```

If you prefer to use the block style:

```ruby
DebugLogging.configure do |config|
  config.logger = Logger.new($stdout) # probably want to override to be the Rails.logger, and if so you can't set it in the initializer, as it needs to be set after Rails.logger is set.
  config.log_level = :debug # at what level do the messages created by this gem sent at?
  config.multiple_last_hashes = false # pass every hash argument to last_hash_to_s_proc?
  config.last_hash_to_s_proc = nil # e.g. ->(hash) { "keys: #{hash.keys}" }
  config.last_hash_max_length = 1_000
  config.args_to_s_proc = nil # e.g. ->(record) { "record id: #{record.id}" }
  config.args_max_length = 1_000
  config.instance_benchmarks = false
  config.class_benchmarks = false
  config.active_support_notifications = false
  config.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
  config.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
  config.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
  config.ellipsis = ' ✂️ …'.freeze
  config.mark_scope_exit = true # Only has an effect if benchmarking is off, since benchmarking always marks the scope exit
  config.add_payload = false # or a proc which will be called to print the payload
  config.payload_max_length = 1000
  config.error_handler_proc = nil # e.g. ->(error, config, obj, method_name, args) { config.log { "#{error.class}: #{error.message} in #{method_name}\nargs: #{args.inspect}" } }
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

Every time a method is called, you can now get logs, optionally with arguments, a benchmark, and a unique invocation identifier:

```ruby
class Car
  # Adds the helper methods to the class.
  #   All helpers prefixed with debug_*,
  #   except for the *logged* decorator, which comes from extending DebugLogging::ClassLogger
  extend DebugLogging

  # per class configuration overrides!
  self.debug_class_benchmarks = true
  self.debug_instance_benchmarks = true

  # For class methods
  #   Provides the versatile `logged` method decorator / macro
  # For instance methods
  #   Provides the versatile `i_logged` method decorator / macro
  extend DebugLogging::ClassLogger

  # == BEGIN CLASS METHODS ==
  # For class methods:
  # Option 1: Use *logged* as a method decorator
  logged def self.make
    new
  end
  def self.design(*_args)
    new
  end

  def self.safety(*_args)
    new
  end

  def self.dealer_options(*_args)
    new
  end

  # Option 2: Use *logged* as a macro
  logged :design, :safety
  # Override configuration options for any class method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets logged,
  #     and also made available to last_hash_to_s_proc
  logged :dealer_options, {
    something: 'here', # <= will be logged, and available to last_hash_to_s_proc
    multiple_last_hashes: true # <= Overrides config
  }
  def self.will_not_be_logged
    false
  end
  # == END CLASS METHODS ==

  # == BEGIN INSTANCE METHODS ==
  # For instance methods:
  # Option 1: specify the exact method(s) to add logging to
  include DebugLogging::InstanceLogger.new(i_methods: %i[drive stop])

  def drive(speed)
    speed
  end

  def stop(**_opts)
    0
  end

  # For instance methods:
  # Option 2: add logging to all instance methods defined above (but *not* defined below)
  include DebugLogging::InstanceLogger.new(i_methods: instance_methods(false))

  def faster(**_opts)
    0
  end

  # Override configuration options for any instance method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets logged,
  #     and also made available to last_hash_to_s_proc
  include DebugLogging::InstanceLogger.new(i_methods: [:faster], config: { add_invocation_id: false })

  def will_not_be_logged
    false
  end
  # == END INSTANCE METHODS ==
end
```

### ActiveSupport::Notifications integration

To use `ActiveSupport::Notifications` integration, enable `active_support_notifications` in the config, either single line or block style:

```ruby
DebugLogging.configuration.active_support_notifications = true
```

or

```ruby
DebugLogging.configure do |config|
  config.active_support_notifications = true
end
```

Every time a method is called, class and instance method events are instrumented, consumed and logged:

```ruby
class Car
  # Adds the helper methods to the class.
  #   All helpers prefixed with debug_*,
  #   except for the *notifies* decorator, which comes from extending DebugLogging::ClassNotifier
  extend DebugLogging

  # For instance methods:
  # Option 1: specify the exact method(s) to add instrumentation to
  #   NOTE: You can capture instance variable values as part of the event payload
  include DebugLogging::InstanceNotifier.new(i_methods: [:drive,
                                                         :stop,
                                                         [:turn, { instance_variables: %i[direction angle] }]])

  # For class methods
  #   Provides the versatile `notifies` method decorator / macro
  # For instance methods
  #   Provides the versatile `i_notifies` method decorator / macro
  extend DebugLogging::ClassNotifier

  # == BEGIN CLASS METHODS ==
  # For class methods:
  # Option 1: Use *notifies* as a method decorator
  notifies def self.make
    new
  end
  def self.design(*_args)
    new
  end

  def self.safety(*_args)
    new
  end

  def self.dealer_options(*_args)
    new
  end

  # Option 2: Use *logged* as a macro
  notifies :design, :safety
  # Override configuration options for any class method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets added to the event payload,
  #     and also made available to last_hash_to_s_proc
  notifies :dealer_options, {
    something: 'here', # <= will be added to the event payload, and be available to last_hash_to_s_proc
    add_invocation_id: false # <= Overrides config
  }
  def self.will_not_be_notified
    false
  end
  # == END CLASS METHODS ==

  # == BEGIN INSTANCE METHODS ==
  def drive(speed)
    speed
  end

  def stop(**_opts)
    0
  end

  # For instance methods:
  # Option 2: add instrumentation to all instance methods defined above (but *not* defined below)
  include DebugLogging::InstanceNotifier.new(i_methods: instance_methods(false))

  def faster(**_opts)
    0
  end

  # Override options for any instance method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets added to the event payload,
  #     and also made available to last_hash_to_s_proc
  include DebugLogging::InstanceNotifier.new(i_methods: [:faster], config: { add_invocation_id: false })

  def will_not_be_notified
    false
  end
  # == END INSTANCE METHODS ==
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
spec.add_dependency 'debug_logging', '~> 3.1'
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

### License Exceptions

* [`debug_logging/finalize`](https://stackoverflow.com/a/34559282) is licensed under https://creativecommons.org/licenses/by-sa/4.0/

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[coderwall]: http://coderwall.com/pboling
[angellist]: https://angel.co/peter-boling
[documentation]: http://rdoc.info/github/pboling/debug_logging/frames
[homepage]: https://github.com/pboling/debug_logging
[blogpage]: http://www.railsbling.com/tags/debug_logging/
