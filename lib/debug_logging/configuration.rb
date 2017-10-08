module DebugLogging
  class Configuration
    DEFAULT_ELLIPSIS = " ✂️ …".freeze
    # LEVELS = { 0 => :debug, 1 => :info, 2 => :warn, 3 => :error, 4 => :fatal, 5 => :unknown }
    attr_accessor :logger
    attr_accessor :log_level
    attr_accessor :multiple_last_hashes
    attr_accessor :last_hash_to_s_proc
    attr_accessor :last_hash_max_length
    attr_accessor :args_max_length
    attr_accessor :instance_benchmarks
    attr_accessor :class_benchmarks
    attr_accessor :colorized_chain_for_method
    attr_accessor :colorized_chain_for_class
    attr_accessor :add_invocation_id
    attr_accessor :ellipsis
    attr_accessor :mark_scope_exit
    attr_reader :methods_to_log
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
    #           args_max_length: 1_000
    #           instance_benchmarks: false
    #           class_benchmarks: false
    #           add_invocation_id: true # invocation id allows you to identify a method call uniquely in a log
    #           ellipsis: " ✂️ …".freeze
    #       }
    #     )
    #
    alias :debug_logger :logger
    alias :debug_log_level :log_level
    alias :debug_multiple_last_hashes :multiple_last_hashes
    alias :debug_last_hash_to_s_proc :last_hash_to_s_proc
    alias :debug_last_hash_max_length :last_hash_max_length
    alias :debug_args_max_length :args_max_length
    alias :debug_instance_benchmarks :instance_benchmarks
    alias :debug_class_benchmarks :class_benchmarks
    alias :debug_colorized_chain_for_method :colorized_chain_for_method
    alias :debug_colorized_chain_for_class :colorized_chain_for_class
    alias :debug_add_invocation_id :add_invocation_id
    alias :debug_ellipsis :ellipsis
    alias :debug_mark_scope_exit :mark_scope_exit
    def initialize(**options)
      @logger = options.key?(:logger) ? options[:logger] : Logger.new(STDOUT)
      @log_level = options.key?(:log_level) ? options[:log_level] : :debug
      @multiple_last_hashes = options.key?(:multiple_last_hashes) ? options[:multiple_last_hashes] : false
      @last_hash_to_s_proc = options.key?(:last_hash_to_s_proc) ? options[:last_hash_to_s_proc] : nil
      @last_hash_max_length = options.key?(:last_hash_max_length) ? options[:last_hash_max_length] : 1_000
      @args_max_length = options.key?(:args_max_length) ? options[:args_max_length] : 1_000
      @instance_benchmarks = options.key?(:instance_benchmarks) ? options[:instance_benchmarks] : false
      @class_benchmarks = options.key?(:class_benchmarks) ? options[:class_benchmarks] : false
      @colorized_chain_for_method = options.key?(:colorized_chain_for_method) ? options[:colorized_chain_for_method] : false
      @colorized_chain_for_class = options.key?(:colorized_chain_for_class) ? options[:colorized_chain_for_class] : false
      @add_invocation_id = options.key?(:add_invocation_id) ? options[:add_invocation_id] : true
      @ellipsis = options.key?(:ellipsis) ? options[:ellipsis] : DEFAULT_ELLIPSIS
      @mark_scope_exit = options.key?(:mark_scope_exit) ? options[:mark_scope_exit] : false
      @methods_to_log = []
    end
    def log(message = nil, &block)
      return unless logger
      if block_given?
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
      @benchmarkable = loggable? && self.send(benchmarks)
    end
    def exit_scope_markable?
      return @exit_scope_markable if defined?(@exit_scope_markable)
      @exit_scope_markable = loggable? && mark_scope_exit
    end
    def instance_benchmarks=(instance_benchmarks)
      require "benchmark" if instance_benchmarks
      @instance_benchmarks = instance_benchmarks
    end
    def class_benchmarks=(class_benchmarks)
      require "benchmark" if class_benchmarks
      @class_benchmarks = class_benchmarks
    end
    def to_hash
      {
          logger: logger,
          log_level: log_level,
          multiple_last_hashes: multiple_last_hashes,
          last_hash_to_s_proc: last_hash_to_s_proc,
          last_hash_max_length: last_hash_max_length,
          args_max_length: args_max_length,
          instance_benchmarks: instance_benchmarks,
          class_benchmarks: class_benchmarks,
          colorized_chain_for_method: colorized_chain_for_method,
          colorized_chain_for_class: colorized_chain_for_class,
          add_invocation_id: add_invocation_id,
          ellipsis: ellipsis
      }
    end
    def register(method_lo_log)
      @methods_to_log << method_lo_log
    end
  end
end
