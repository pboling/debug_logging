require "logger"
require "debug_logging/version"
require "debug_logging/configuration"
require "debug_logging/argument_printer"
require "debug_logging/instance_logger_modulizer"
require "debug_logging/instance_logger"
require "debug_logging/class_logger"

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
#       # adds the helper methods to the class, all are prefixed with debug_*,
#       #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
#       extend DebugLogging
#
#       # per class configuration overrides!
#       self.debug_class_benchmarks = true
#       self.debug_instance_benchmarks = true
#
#       # For instance methods:
#       # Option 1: specify the exact method(s) to add logging to
#       include DebugLogging::InstanceLogger.new(i_methods: [:drive, :stop])
#
#       extend DebugLogging::ClassLogger
#
#       logged def debug_make; new; end
#       def design(*args); new; end
#       def safety(*args); new; end
#       logged :design, :safety
#
#       def drive(speed); speed; end
#       def stop; 0; end
#
#       # For instance methods:
#       # Option 2: add logging to all instance methods defined above (but *not* defined below)
#       include DebugLogging::InstanceLogger.new(i_methods: debug_instance_methods(false))
#
#       def will_not_be_logged; false; end
#
#     end
#                  #
####################

module DebugLogging
  def self.extended(base)
    base.send(:extend, ArgumentPrinter)
    base.debug_config_reset(debug_logging_configuration.dup)
  end

  #### API ####
  def debug_log(message)
    debug_logger.send(debug_log_level, message)
  end

  # There are times when the class will need access to the configuration object,
  #   such as to override it per instance method
  def debug_config
    @debug_logging_configuration
  end

  # For single statement global config in an initializer
  # e.g. DebugLogging.configuration.ellipsis = "..."
  def self.configuration
    self.debug_logging_configuration ||= Configuration.new
  end

  # For global config in an initializer with a block
  def self.configure
    yield(configuration)
  end

  # For per-class config with a block
  def debug_logging_configure
    @debug_logging_configuration ||= Configuration.new
    yield(@debug_logging_configuration)
  end

  #### CONFIG ####
  class << self
    attr_accessor :debug_logging_configuration
  end
  def debug_config_reset(config = Configuration.new)
    @debug_logging_configuration = config
  end
  def debug_logger
    @debug_logging_configuration.logger
  end
  def debug_logger=(logger)
    @debug_logging_configuration.logger = logger
  end
  def debug_log_level
    @debug_logging_configuration.log_level
  end
  def debug_log_level=(log_level)
    @debug_logging_configuration.log_level = log_level
  end
  def debug_multiple_last_hashes
    @debug_logging_configuration.multiple_last_hashes
  end
  def debug_multiple_last_hashes=(multiple_last_hashes)
    @debug_logging_configuration.multiple_last_hashes = multiple_last_hashes
  end
  def debug_last_hash_to_s_proc
    @debug_logging_configuration.last_hash_to_s_proc
  end
  def debug_last_hash_to_s_proc=(last_hash_to_s_proc)
    @debug_logging_configuration.last_hash_to_s_proc = last_hash_to_s_proc
  end
  def debug_last_hash_max_length
    @debug_logging_configuration.last_hash_max_length
  end
  def debug_last_hash_max_length=(last_hash_max_length)
    @debug_logging_configuration.last_hash_max_length = last_hash_max_length
  end
  def debug_args_max_length
    @debug_logging_configuration.args_max_length
  end
  def debug_args_max_length=(args_max_length)
    @debug_logging_configuration.args_max_length = args_max_length
  end
  def debug_instance_benchmarks
    @debug_logging_configuration.instance_benchmarks
  end
  def debug_instance_benchmarks=(instance_benchmarks)
    @debug_logging_configuration.instance_benchmarks = instance_benchmarks
  end
  def debug_class_benchmarks
    @debug_logging_configuration.class_benchmarks
  end
  def debug_class_benchmarks=(class_benchmarks)
    @debug_logging_configuration.class_benchmarks = class_benchmarks
  end
  def debug_add_invocation_id
    @debug_logging_configuration.add_invocation_id
  end
  def debug_add_invocation_id=(add_invocation_id)
    @debug_logging_configuration.add_invocation_id = add_invocation_id
  end
  def debug_ellipsis
    @debug_logging_configuration.ellipsis
  end
  def debug_ellipsis=(ellipsis)
    @debug_logging_configuration.ellipsis = ellipsis
  end
  self.debug_logging_configuration = Configuration.new # setup defaults
end
