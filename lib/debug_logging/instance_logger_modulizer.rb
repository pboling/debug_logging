# frozen_string_literal: true

module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log: nil, payload: nil, config: nil)
      Module.new do
        methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: Array(methods_to_log),
          payload: payload,
          config: config,
        )
        Array(methods_to_log).each do |method_to_log|
          method_to_log, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
            method_names: method_to_log,
            payload: payload,
            config: config_opts,
          )
          define_method(method_to_log) do |*args, &block|
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
            invocation_id = self.class.debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
            config_proxy.log do
              paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: self, payload: method_payload)
              signature = self.class.debug_signature_to_s(args: args, config_proxy: config_proxy)
              paymud = debug_payload_to_s(payload: paydirt, config_proxy: config_proxy)
              "#{log_prefix}#{signature}#{invocation_id} debug: #{paymud}"
            end
            if config_proxy.benchmarkable_for?(:debug_instance_benchmarks)
              tms = Benchmark.measure do
                method_return_value = super(*args, &block)
              end
              config_proxy.log do
                "#{log_prefix} #{self.class.debug_benchmark_to_s(tms: tms)}#{invocation_id}"
              end
            else
              begin
                method_return_value = super(*args, &block)
              rescue StandardError => e
                if config_proxy.error_handler_proc
                  config_proxy.error_handler_proc.call(config_proxy, e, self, method_to_log, args)
                else
                  raise e
                end
              end
              if config_proxy.exit_scope_markable? && invocation_id && !invocation_id.empty?
                config_proxy.log do
                  "#{log_prefix} completed#{invocation_id}"
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
