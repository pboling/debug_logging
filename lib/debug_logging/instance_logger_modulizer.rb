module DebugLogging
  module InstanceLoggerModulizer
    class << self
      def to_mod(methods_to_log: nil, payload: nil, config: nil)
        Module.new do
          methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
            method_names: Array(methods_to_log),
            payload:,
            config:,
          )
          Array(methods_to_log).each do |method_to_log|
            method_to_log, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
              method_names: method_to_log,
              payload:,
              config: config_opts,
            )
            define_method(method_to_log) do |*args, **kwargs, &block|
              method_return_value = nil
              config_proxy = DebugLogging::Util.config_proxy_finder(
                scope: self.class,
                config_opts: method_config_opts,
                method_name: method_to_log,
                proxy_ref: "ilm",
              )
              log_prefix = self.class.debug_invocation_to_s(
                klass: self.class.to_s,
                separator: "#",
                method_to_log: method_to_log,
                config_proxy: config_proxy,
              )
              start_at = Time.now
              start_timestamp = self.class.debug_time_to_s(start_at, config_proxy:)
              invocation_id = self.class.debug_invocation_id_to_s(args:, kwargs:, start_at:, config_proxy:)
              config_proxy.log do
                paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: self, payload: method_payload)
                signature = self.class.debug_signature_to_s(args:, kwargs:, config_proxy:)
                paymud = debug_payload_to_s(payload: paydirt, config_proxy:)
                "#{start_timestamp}#{log_prefix}#{signature}#{invocation_id} debug: #{paymud}"
              end
              if config_proxy.benchmarkable_for?(:debug_instance_benchmarks)
                tms = Benchmark.measure do
                  method_return_value = super(*args, **kwargs, &block)
                end
                end_timestamp = self.class.debug_time_to_s(Time.now, config_proxy:)
                config_proxy.log do
                  "#{end_timestamp}#{log_prefix} #{self.class.debug_benchmark_to_s(tms: tms)}#{invocation_id}"
                end
              else
                begin
                  method_return_value = super(*args, **kwargs, &block)
                rescue StandardError => e
                  if config_proxy.error_handler_proc
                    config_proxy.error_handler_proc.call(config_proxy, e, self, method_to_log, args, kwargs)
                  else
                    raise e
                  end
                end
                if config_proxy.exit_scope_markable? && invocation_id && !invocation_id.empty?
                  end_timestamp = self.class.debug_time_to_s(Time.now, config_proxy:)
                  config_proxy.log do
                    "#{end_timestamp}#{log_prefix} completed#{invocation_id}"
                  end
                end
              end
              method_return_value
            end
          end
        end
      end
    end
  end
end
