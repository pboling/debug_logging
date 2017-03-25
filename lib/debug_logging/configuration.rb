module DebugLogging
  class Configuration
    attr_accessor :logger
    attr_accessor :log_level
    attr_accessor :last_hash_to_s_proc
    attr_accessor :last_hash_max_length
    attr_accessor :args_max_length
    attr_accessor :instance_benchmarks
    attr_accessor :class_benchmarks
    attr_accessor :add_invocation_id
    attr_accessor :ellipsis
    def initialize
      @logger = Logger.new(STDOUT)
      @log_level = :debug
      @last_hash_to_s_proc = nil
      @last_hash_max_length = 1_000
      @args_max_length = 1_000
      @instance_benchmarks = false
      @class_benchmarks = false
      @add_invocation_id = true
      @ellipsis = " ✂️ …".freeze
    end
    def instance_benchmarks=(instance_benchmarks)
      require "benchmark" if instance_benchmarks
      @instance_benchmarks = instance_benchmarks
    end
    def class_benchmarks=(class_benchmarks)
      require "benchmark" if class_benchmarks
      @class_benchmarks = class_benchmarks
    end
  end
end
