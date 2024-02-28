# DebugLogging

<div id="badges">

[![CI Build][🚎dl-cwfi]][🚎dl-cwf]
[![Test Coverage][🔑cc-covi]][🔑cc-cov]
[![Maintainability][🔑cc-mnti]][🔑cc-mnt]
[![Depfu][🔑depfui]][🔑depfu]

-----

[![Liberapay Patrons][⛳liberapay-img]][⛳liberapay]
[![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor]
<span class="badge-buymeacoffee">
<a href="https://ko-fi.com/O5O86SNP4" target='_blank' title="Donate to my FLOSS or refugee efforts at ko-fi.com"><img src="https://img.shields.io/badge/buy%20me%20coffee-donate-yellow.svg" alt="Buy me coffee donation button" /></a>
</span>
<span class="badge-patreon">
<a href="https://patreon.com/galtzo" title="Donate to my FLOSS or refugee efforts using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a>
</span>

</div>

[⛳liberapay-img]: https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling


Unobtrusive, inheritable-overridable-configurable, drop-in debug logging, instrumented via method decorators.
Don't leave a mess behind when it is time to remove logging!
Supports `ActiveSupport::Notifications` (thanks [@jgillson](https://github.com/jgillson)).  Optional ActiveRecord callback-style hooks that you can decorate your methods with. Hooks logic was taken from the [`slippy_method_hooks` gem](https://github.com/guckin/slippy_method_hooks), (thanks [@guckin](https://github.com/guckin)), and prefaced with `debug_` for this implementation. `DebugLogging::Finalize` is lightly modified from [this stackoverflow answer](https://stackoverflow.com/a/34559282).

## What do I mean by "unobtrusive"?

**Ugly** debug logging is added inside the body of a method, so it runs when a method is called. This can create a mess of your git history, and can even introduce new bugs to your code.  Don't `puts` all over your codebase...  Instead use this gem.

**Unobtrusive** debug logging stays out of the method, changes no logic, can't break your code, and yet it still runs when your method is called, and tells you everything you wanted to know. It doesn't mess with the git history of the method at all!

| Project                | DebugLogging                                                                                                                                                                                                                                                                                                                     |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| install                | `bundle add debug_logging`                                                                                                                                                                                                                                                                                                       |
| compatibility          | Ruby >= 3.1 (use version 3.x for Ruby 2.4 - 2.7 compatibility)                                                                                                                                                                                                                                                                   |
| license                | [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)                                                                                                                                                                                                                       |
| download rank          | [![Downloads Today](https://img.shields.io/gem/rd/debug_logging.svg)](https://github.com/pboling/debug_logging)                                                                                                                                                                                                                  |
| version                | [![Version](https://img.shields.io/gem/v/debug_logging.svg)](https://rubygems.org/gems/debug_logging)                                                                                                                                                                                                                            |
| code triage            | [![Open Source Helpers](https://www.codetriage.com/pboling/debug_logging/badges/users.svg)](https://www.codetriage.com/pboling/debug_logging)                                                                                                                                                                                    |
| documentation          | [on RDoc.info][documentation]                                                                                                                                                                                                                                                                                                    |
| live chat              | [![Join the chat at https://gitter.im/pboling/debug_logging](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pboling/debug_logging?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)                                                                                                       |
| expert support         | [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github)                                                                                                                            |
| Spread ~♡ⓛⓞⓥⓔ♡~        | [🌏](https://about.me/peter.boling), [👼](https://angel.co/peter-boling), [![Liberapay Patrons][⛳liberapay-img]][⛳liberapay] [![Follow Me on LinkedIn][🖇linkedin-img]][🖇linkedin] [![Find Me on WellFound:][✌️wellfound-img]][✌️wellfound] [![My Blog][🚎blog-img]][🚎blog] [![Follow Me on Twitter][🐦twitter-img]][🐦twitter] |

[🚎dl-cwf]: https://github.com/pboling/debug_logging/actions/workflows/current.yml
[🚎dl-cwfi]: https://github.com/pboling/debug_logging/actions/workflows/current.yml/badge.svg

[⛳liberapay-img]: https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇linkedin]: http://www.linkedin.com/in/peterboling
[🖇linkedin-img]: https://img.shields.io/badge/PeterBoling-blue?style=plastic&logo=linkedin
[✌️wellfound]: https://angel.co/u/peter-boling
[✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=plastic&logo=angellist
[🐦twitter]: http://twitter.com/intent/user?screen_name=galtzo
[🐦twitter-img]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow%20@galtzo
[🚎blog]: http://www.railsbling.com/tags/oauth2/
[🚎blog-img]: https://img.shields.io/badge/blog-railsbling-brightgreen.svg?style=flat
[my🧪lab]: https://gitlab.com/pboling
[my🧊berg]: https://codeberg.org/pboling
[my🛖hut]: https://sr.ht/~galtzo/

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

* ~~Classes inheriting from Module~~ Refactored to use standard Modules and `prepend`!
* Zero tolerance policy on monkey patching
  * When the gem is loaded there are no monkey patches.
  * Rather, your own classes/methods get "patched" and "hooked" as you configure them.
* 100% clean, 0% obtrusive
* Greater than 94% test coverage & 82% branch coverage
* 100% Ruby 2.1+ compatible
  - use version `gem "debug_logging", "~> 1.0"` for Ruby < 2.3
  - use version `gem "debug_logging", "~> 2.0"` for Ruby 2.3
  - use version `gem "debug_logging", "~> 3.1"` for Ruby >= 2.4, < 3
  - apologies to Ruby 3.0, which is hiding under a blanket
  - use version `gem "debug_logging", "~> 4.0"` for Ruby >= 3.1

## Installation

Add this line to your application's Gemfile:

```ruby
gem "debug_logging", "~> 4.0"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debug_logging

## Usage

Crack open the specs for more complex usage examples than the ones below.

### First, how do I turn it off when I need some silence?

For example, in your test suite, before you `require "config/environment"` or equivalent, do this:

```ruby
require "logger"
require "debug_logging"

logger = Logger.new($stdout)
logger.level = Logger::UNKNOWN # for silence!
DebugLogging.configuration.logger = logger
```

It will silence all of the places that have `extend DebugLogger`, _unless_ those places have overridden the logger config they inherited from the global config.

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
DebugLogging.configuration.args_to_s_proc = nil # e.g. ->(*record) { "record id: #{record.first.id}" }
DebugLogging.configuration.args_max_length = 1_000
DebugLogging.configuration.instance_benchmarks = false
DebugLogging.configuration.class_benchmarks = false
DebugLogging.configuration.active_support_notifications = false
DebugLogging.configuration.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
DebugLogging.configuration.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
DebugLogging.configuration.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
DebugLogging.configuration.ellipsis = " ✂️ …".freeze
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
  config.args_to_s_proc = nil # e.g. ->(*record) { "record id: #{record.first.id}" }
  config.args_max_length = 1_000
  config.instance_benchmarks = false
  config.class_benchmarks = false
  config.active_support_notifications = false
  config.colorized_chain_for_method = false # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
  config.colorized_chain_for_class = false # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
  config.add_invocation_id = true # identify a method call uniquely in a log, pass a proc for colorization, e.g. ->(colorized_string) { colorized_string.light_black }
  config.ellipsis = " ✂️ …".freeze
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
Just send along a hash of the config options, similar to the following:

- `logged :drive, { ellipsis: " ✂️ it out" }`
- `i_logged [:drive, :stop], { ellipsis: " ✂️ 2 much" }`
- `notified :drive, { ellipsis: " ✂️ it out" }`
- `i_notified [:drive, :stop], { ellipsis: " ✂️ 2 much" }`

See the example class below, and the specs.

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
  extend DebugLogging::ClassLogger
  # For instance methods
  #   Provides the versatile `i_logged` method decorator / macro
  extend DebugLogging::InstanceLogger

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
    something: "here", # <= will be logged, and available to last_hash_to_s_proc
    multiple_last_hashes: true, # <= Overrides config
  }
  def self.will_not_be_logged
    false
  end
  # == END CLASS METHODS ==

  # == BEGIN INSTANCE METHODS ==
  # For instance methods:
  # Option 1: specify the exact method(s) to add logging to, and optionally customize
  i_notified [
    :drive,
    :stop,
    [:turn, {instance_variables: %i[direction angle]}],
  ]

  def drive(speed)
    speed
  end

  def stop(**_opts)
    0
  end

  # For instance methods:
  # Option 2: add logging to all instance methods defined above (but *not* defined below)
  i_logged instance_methods(false)

  def faster(**_opts)
    5
  end

  # Override configuration options for any instance method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets logged,
  #     and also made available to last_hash_to_s_proc
  i_logged [:faster], config: {add_invocation_id: false}

  # You can also use `i_logged` as a true method decorator:
  i_logged def slower
    2
  end

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
  #   except for the *notified* decorator, which comes from extending DebugLogging::ClassNotifier
  extend DebugLogging
  # For instance methods
  #   Provides the versatile `i_notified` method decorator / macro
  extend DebugLogging::InstanceNotifier
  # For class methods
  #   Provides the versatile `notified` method decorator / macro
  extend DebugLogging::ClassNotifier

  # For instance methods:
  # Option 1: specify the exact method(s) to add instrumentation to
  #   NOTE: You can capture instance variable values as part of the event payload
  i_notified [
    :drive,
    :stop,
    [:turn, {instance_variables: %i[direction angle]}],
  ]

  # == BEGIN CLASS METHODS ==
  # For class methods:
  # Option 1: Use *notified* as a method decorator
  notified def self.make
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
  notified :design, :safety
  # Override configuration options for any class method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets added to the event payload,
  #     and also made available to last_hash_to_s_proc
  notified :dealer_options, {
    something: "here", # <== will be added to the event payload, and be available to last_hash_to_s_proc
    add_invocation_id: false, # <== Overrides config
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
  # Option 2: add notification instrumentation to all instance methods defined above (but *not* defined below)
  i_notified instance_methods(false)

  def faster(**_opts)
    0
  end

  # Override options for any instance method(s), by passing a hash as the last argument
  # In the last hash any non-Configuration keys will be data that gets added to the event payload,
  #     and also made available to last_hash_to_s_proc
  i_notified [:faster], config: {add_invocation_id: false}

  def will_not_be_notified
    false
  end
  # == END INSTANCE METHODS ==
end
```

## Development

Run tests!

```shell
bundle install
bundle exec rake
```

## Contributing

See [CONTRIBUTING.md][🪇conduct]

[🪇conduct]: CONTRIBUTING.md

## 🪇 Code of Conduct

Everyone interacting in this project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct][🪇conduct].

[🪇conduct]: CODE_OF_CONDUCT.md

## 📌 Versioning

This Library adheres to [Semantic Versioning 2.0.0][📌semver].
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API will only be introduced with new major versions.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

As a result of this policy, you can (and should) specify a dependency on these libraries using
the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("debug_logging", "~> 4.0")
```

[comment]: <> ( VERSIONING LINKS )

[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: http://semver.org/
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html

## 📄 License

The gem is available as open source under the terms of
the [MIT License][📄license] [![License: MIT][📄license-img]][📄license-ref], with one exception:

* [`lib/debug_logging/finalize.rb`](lib/debug_logging/finalize.rb) came from [this StackOverflow](https://stackoverflow.com/a/34559282).
  * As such, it is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

See [LICENSE.txt][📄license] for the official [Copyright Notice][📄copyright-notice-explainer].

[comment]: <> ( LEGAL LINKS )

[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.txt
[📄license-ref]: https://opensource.org/licenses/MIT
[📄license-img]: https://img.shields.io/badge/License-MIT-green.svg

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[coderwall]: http://coderwall.com/pboling
[angellist]: https://angel.co/peter-boling
[documentation]: http://rdoc.info/github/pboling/debug_logging/frames
[homepage]: https://github.com/pboling/debug_logging
[blogpage]: http://www.railsbling.com/tags/debug_logging/

[comment]: <> ( PERSONAL LINKS )

[💁🏼‍♂️aboutme]: https://about.me/peter.boling
[💁🏼‍♂️angellist]: https://angel.co/peter-boling
[💁🏼‍♂️devto]: https://dev.to/galtzo
[💁🏼‍♂️followme]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow
[💁🏼‍♂️twitter]: http://twitter.com/galtzo

[comment]: <> ( KEYED LINKS )

[🔑cc-mnt]: https://codeclimate.com/github/pboling/debug_logging/maintainability
[🔑cc-mnti]: https://api.codeclimate.com/v1/badges/1f36d7019c3b81cae1a2/maintainability
[🔑cc-cov]: https://codeclimate.com/github/pboling/debug_logging/test_coverage
[🔑cc-covi]: https://api.codeclimate.com/v1/badges/1f36d7019c3b81cae1a2/test_coverage
[🔑depfu]: https://depfu.com/github/pboling/debug_logging?project_id=2675
[🔑depfui]: https://badges.depfu.com/badges/d1a4cf43255916521fef1e3685c61faa/count.svg
