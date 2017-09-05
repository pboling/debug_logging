# DebugLogging

## Next Level Magic

* Classes inheriting from Module.
* Cats and dogs sleeping together.
* Yet this gem monkey patches nothing.
* 100% clean.
* 0% obtrusive.
* 100% tested.
* 50% Ruby 2.0+ compatible.
* 100% Ruby 2.1+ compatible.
* 10g Monosodium glutamate.

NOTE: The manner this is made to work for class methods is totally different than the way this is made to work for instance methods.

NOTE: The instance method logging works on Ruby 2.0+

NOTE: The class method logging works on Ruby 2.1+

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

Crack open the specs for usage examples.

### Without Rails

It just works. ;)
Configuration can go anywhere you want.  It will look like the Rails config though; see below.

### With Rails

Recommend creating `config/initializers/debug_logging.rb` with:

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
end
```

**All** of the above **config** is **inheritable** and **configurable** at the **per-class** level as well!
Just prepend `debug_` to any config value you want to override in a class.

**All** of the above **config** is **inheritable** and **configurable** at the **per-method** level as well!
Just send along a hash of the config options when you call `logged` or `include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop])`.  See the example class below, and the specs.

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
