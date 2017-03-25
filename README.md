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
Configuration can go anywhere you want.

### With Rails

Recommend creating `config/initializers/debug_logging.rb` with:
```ruby
# Showing the defaults
DebugLogging.logger = Logger.new(STDOUT) # you probably want to override to be the Rails.logger
DebugLogging.log_level = :debug # at what level do the messages created by this gem sent at?
DebugLogging.last_hash_to_s_proc = nil # e.g. ->(hash) { "#{hash.keys}" }
DebugLogging.last_hash_max_length = 1_000
DebugLogging.args_max_length = 1_000
DebugLogging.instance_benchmarks = false
DebugLogging.class_benchmarks = false
DebugLogging.add_invocation_id = true # invocation id allows you to identify a method call uniquely in a log
DebugLogging.ellipsis = " ✂️ …".freeze
```

```ruby
class Car

  # For instance methods:
  # Option 1: specify the exact method(s) to add logging to
  include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop])
  
  extend DebugLogging::ClassLogger
  
  logged def self.make; new; end
  def self.design(*args); new; end
  def self.safety(*args); new; end
  logged :design, :safety
  
  def drive(speed); speed; end
  def stop; 0; end
  
  # For instance methods:
  # Option 2: add logging to all instance methods defined above (but *not* defined below)
  include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
  
  def will_not_be_logged; false; end

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/debug_logging.
