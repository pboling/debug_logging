# frozen_string_literal: true

module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_log,
        payload: nil,
        config: nil,
      )
      Array(methods_to_log).each do |method_to_log|
        method_to_log, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: method_to_log,
          payload: payload,
          config: config_opts,
        )
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log) do |*args, &block|
            config_proxy = DebugLogging::Util.config_proxy_finder(
              scope: self,
              config_opts: method_config_opts,
              method_name: method_to_log,
              proxy_ref: "kl",
            )
            method_return_value = nil
            log_prefix = nil
            invocation_id = nil
            begin
              config_proxy.log do
                paydirt = DebugLogging::Util.payload_instance_vaiable_hydration(scope: self, payload: method_payload)
                log_prefix = debug_invocation_to_s(
                  klass: to_s,
                  separator: ".",
                  method_to_log: method_to_log,
                  config_proxy: config_proxy,
                )
                invocation_id = debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
                signature = debug_signature_to_s(args: args, config_proxy: config_proxy)
                paymud = debug_payload_to_s(payload: paydirt, config_proxy: config_proxy)
                "#{log_prefix}#{signature}#{invocation_id} debug: #{paymud}"
              end
              if config_proxy.benchmarkable_for?(:debug_class_benchmarks)
                tms = Benchmark.measure do
                  method_return_value = if args.size == 1 && (harsh = args[0]) && harsh.is_a?(Hash)
                    original_method.call(**harsh, &block)
                  else
                    original_method.call(*args, &block)
                  end
                end
                config_proxy.log do
                  "#{log_prefix} #{debug_benchmark_to_s(tms: tms)}#{invocation_id}"
                end
              else
                method_return_value = if args.size == 1 && (harsh = args[0]) && harsh.is_a?(Hash)
                  original_method.call(**harsh, &block)
                else
                  original_method.call(*args, &block)
                end
                if config_proxy.exit_scope_markable? && invocation_id && !invocation_id.empty?
                  config_proxy.log do
                    "#{log_prefix} completed#{invocation_id}"
                  end
                end
              end
              method_return_value
            rescue StandardError => e
              if config_proxy.error_handler_proc
                config_proxy.error_handler_proc.call(config_proxy, e, self, method_to_log, args)
              else
                raise e
              end
            end
          end
        end
      end
    end
  end
end
