require "logger"
require "debug_logging/version"
require "debug_logging/argument_printer"
require "debug_logging/instance_logger_modulizer"
require "debug_logging/instance_logger"
require "debug_logging/class_logger"

####################
#                  #
# Next Level Magic #
# Classes inheriting from Module.
# Cats and dogs sleeping together.
#                  #
####################
#                  #
# NOTE: The manner this is made to work for class methods is totally different
#       than the way this is made to work for instance methods.
# NOTE: The instance method manner works on Ruby 2.0+
# NOTE: The class method manner works on Ruby 2.1+
#                  #
####################
#                  #
# USAGE (see specs)#
#                  #
#     class Car
#
#       # For instance methods:
#       # Option 1: specify the exact method(s) to add logging to
#       include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop])
#
#       extend DebugLogging::ClassLogger
#
#       logged def self.make; new; end
#       def self.design(*args); new; end
#       def self.safety(*args); new; end
#       logged :design, :safety
#
#       def drive(speed); speed; end
#       def stop; 0; end
#
#       # For instance methods:
#       # Option 2: add logging to all instance methods defined above (but *not* defined below)
#       include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
#
#       def will_not_be_logged; false; end
#
#     end
#                  #
####################

module DebugLogging
  def self.config_reset
    @@logger = nil
    @@log_level = :debug
    @@last_hash_to_s_proc = nil
    @@last_hash_max_length = 1_000
    @@args_max_length = 1_000
    @@instance_benchmarks = false
    @@class_benchmarks = false
    @@add_invocation_id = true
    @@ellipsis = " ✂️ …".freeze
  end
  def self.logger
    @@logger ||= Logger.new(STDOUT)
  end
  def self.logger=(logger)
    @@logger = logger
  end
  def self.log_level
    @@log_level || :debug
  end
  def self.log_level=(log_level)
    @@log_level = log_level
  end
  def self.last_hash_to_s_proc
    @@last_hash_to_s_proc
  end
  def self.last_hash_to_s_proc=(last_hash_to_s_proc)
    @@last_hash_to_s_proc = last_hash_to_s_proc
  end
  def self.last_hash_max_length
    @@last_hash_max_length || 1_000
  end
  def self.last_hash_max_length=(last_hash_max_length)
    @@last_hash_max_length = last_hash_max_length
  end
  def self.args_max_length
    @@args_max_length || 1_000
  end
  def self.args_max_length=(args_max_length)
    @@args_max_length = args_max_length
  end
  def self.instance_benchmarks
    @@instance_benchmarks
  end
  def self.instance_benchmarks=(instance_benchmarks)
    require "benchmark" if instance_benchmarks
    @@instance_benchmarks = instance_benchmarks
  end
  def self.class_benchmarks
    @@class_benchmarks
  end
  def self.class_benchmarks=(class_benchmarks)
    require "benchmark" if class_benchmarks
    @@class_benchmarks = class_benchmarks
  end
  def self.add_invocation_id
    @@add_invocation_id
  end
  def self.add_invocation_id=(add_invocation_id)
    @@add_invocation_id = add_invocation_id
  end
  def self.ellipsis
    @@ellipsis
  end
  def self.ellipsis=(ellipsis)
    @@ellipsis = ellipsis
  end
  def self.log(message)
    logger.send(log_level, message)
  end
  config_reset # setup defaults
end
