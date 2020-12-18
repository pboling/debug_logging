# frozen_string_literal: true

module DebugLogging
  class Configuration
    DEFAULT_ELLIPSIS = ' ✂️ …'
    CONFIG_ATTRS_DEFAULTS = {
      enabled: true,
      logger: Logger.new($stdout),
      log_level: :debug,
      multiple_last_hashes: false,
      last_hash_to_s_proc: nil,
      last_hash_max_length: 1_000,
      args_to_s_proc: nil,
      args_max_length: 1_000,
      colorized_chain_for_method: false,
      colorized_chain_for_class: false,
      add_invocation_id: true,
      ellipsis: DEFAULT_ELLIPSIS,
      mark_scope_exit: false,
      add_payload: true, # Can also be a proc returning a string, which will be called when printing the payload
      payload_max_length: 1_000
    }.freeze
    CONFIG_ATTRS = CONFIG_ATTRS_DEFAULTS.keys
    CONFIG_READERS_DEFAULTS = {
      instance_benchmarks: false,
      class_benchmarks: false,
      active_support_notifications: false
    }.freeze
    CONFIG_READERS = CONFIG_READERS_DEFAULTS.keys
    CONFIG_KEYS = CONFIG_ATTRS + CONFIG_READERS

    # For reference, log levels as integers mapped to symbols:
    # LEVELS = { 0 => :debug, 1 => :info, 2 => :warn, 3 => :error, 4 => :fatal, 5 => :unknown }
    attr_accessor(*CONFIG_ATTRS)
    attr_reader :methods_to_log, *CONFIG_READERS

    # alias the readers to the debug_* prefix so an instance of this class
    #   can have the same API granted by `extend DebugLogging`
    #
    #     include DebugLogging::InstanceLogger.new(
    #       i_methods: [:drive, :stop],
    #       config: {
    #           logger: Logger.new(STDOUT) # probably want to override to be the Rails.logger
    #           log_level: :debug # at what level do the messages created by this gem sent at?
    #           last_hash_to_s_proc: nil # e.g. ->(hash) { "keys: #{hash.keys}" }
    #           last_hash_max_length: 1_000
    #           args_to_s_proc: nil # e.g. ->(record) { "record id: #{record.id}" }
    #           args_max_length: 1_000
    #           instance_benchmarks: false
    #           class_benchmarks: false
    #           add_invocation_id: true # invocation id allows you to identify a method call uniquely in a log
    #           ellipsis: " ✂️ …".freeze
    #       }
    #     )
    #
    CONFIG_KEYS.each do |key|
      alias_method :"debug_#{key}", :"#{key}"
    end

    class << self
      def config_pointer(type, method_to_log)
        # Methods names that do not match the following regex can't be part of an ivar name
        #   /[a-zA-Z_][a-zA-Z0-9_]*/
        # Thus we have to use a different form of the method name that is compatible with ivar name conventions
        "@debug_logging_config_#{type}_#{Digest::MD5.hexdigest(method_to_log.to_s)}".to_sym
      end
    end
    def initialize(**options)
      CONFIG_ATTRS.each do |key|
        send("#{key}=", get_attr_from_options(options, key))
      end
      CONFIG_READERS.each do |key|
        send("#{key}=", get_reader_from_options(options, key))
      end
      @methods_to_log = []
    end

    def log(message = nil, &block)
      return unless enabled
      return unless logger

      if block
        logger.send(log_level, &block)
      else
        logger.send(log_level, message)
      end
    end

    def loggable?
      return @loggable if defined?(@loggable)

      @loggable = logger.send("#{log_level}?")
    end

    def benchmarkable_for?(benchmarks)
      return @benchmarkable if defined?(@benchmarkable)

      @benchmarkable = loggable? && send(benchmarks)
    end

    def exit_scope_markable?
      return @exit_scope_markable if defined?(@exit_scope_markable)

      @exit_scope_markable = loggable? && mark_scope_exit
    end

    def instance_benchmarks=(instance_benchmarks)
      require 'benchmark' if instance_benchmarks
      @instance_benchmarks = instance_benchmarks
    end

    def class_benchmarks=(class_benchmarks)
      require 'benchmark' if class_benchmarks
      @class_benchmarks = class_benchmarks
    end

    def active_support_notifications=(active_support_notifications)
      require 'debug_logging/active_support_notifications' if active_support_notifications
      @active_support_notifications = active_support_notifications
    end

    def to_hash
      CONFIG_KEYS.each_with_object({}) do |key, hash|
        hash[key] = instance_variable_get("@#{key}")
      end
    end

    def register(method_lo_log)
      @methods_to_log << method_lo_log
    end

    private

    def get_attr_from_options(options, key)
      options.key?(key) ? options[key] : CONFIG_ATTRS_DEFAULTS[key]
    end

    def get_reader_from_options(options, key)
      options.key?(key) ? options[key] : CONFIG_READERS_DEFAULTS[key]
    end
  end
end
