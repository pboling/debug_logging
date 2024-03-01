module DebugLogging
  module InstanceLogger
    # NOTE: These params can be passed in / hidden in a last hash of *args
    # NOTE: They can also be passed in discretely for each method, by passing *args as an array of arrays
    # TODO: Refactor to use modern Ruby 3 *args, **kwargs instead
    # @param logger [Logger] Logger.new($stdout), # probably want to override to be the Rails.logger
    # @param log_level [Symbol] default: :debug, at what level do the messages created by this gem sent at?
    # @param multiple_last_hashes [true, false] default: false,
    # @param last_hash_to_s_proc [nil, Proc] default: nil, e.g. ->(hash) { "keys: #{hash.keys}" }
    # @param last_hash_max_length [Integer] default: 1_000,
    # @param args_to_s_proc [nil, Proc] default: nil, e.g. ->(*record) { "record id: #{record.first.id}" }
    # @param args_max_length [Integer] default: 1_000,
    # @param colorized_chain_for_method [false, Proc] default: false, e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
    # @param colorized_chain_for_class [false, Proc] default: false, e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
    # @param add_invocation_id [true, false] default: true, allows unique identification of method call; association of entry and exit log lines
    # @param ellipsis [String] default: " ✂️ …".freeze,
    # @param mark_scope_exit [true, false] default: false,
    # @param add_payload [true, false, Proc] default: true, # Can also be a proc returning a string, which will be called when printing the payload
    # @param payload_max_length [Integer] default: 1_000,
    # @param error_handler_proc [nil, Proc] default: nil,
    # @param time_formatter_proc [nil, Proc] default: DebugLogging::Constants::DEFAULT_TIME_FORMATTER,
    # @param add_timestamp [true, false] default: false,
    # @param instance_benchmarks [true, false] default: false,
    # @param class_benchmarks [true, false] default: false,
    def i_logged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_log,
        payload: nil,
        config: nil,
      )
      instance_method_modules =
        Array(methods_to_log).map do |method_to_log|
          DebugLogging::InstanceLoggerModulizer.to_mod(
            methods_to_log: Array(method_to_log),
            payload: payload,
            config: config_opts,
          )
        end
      wrapped_in_logs = Module.new do
        singleton_class.send(:define_method, :included) do |host_class|
          instance_method_modules.each do |mod|
            host_class.prepend(mod)
          end
        end
      end

      send(:include, wrapped_in_logs)
    end
  end
end
