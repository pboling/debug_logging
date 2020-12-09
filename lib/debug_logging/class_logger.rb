# frozen_string_literal: true

module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      # When opts are present it will always be a new configuration instance per method
      # When opts are not present it will reuse the class' configuration object
      payload = methods_to_log.last.is_a?(Hash) && methods_to_log.pop.dup || {}
      config_opts = {}
      unless payload.empty?
        DebugLogging::Configuration::CONFIG_KEYS.each { |k| config_opts[k] = payload.delete(k) if payload.key?(k) }
      end
      if methods_to_log.first.is_a?(Array)
        methods_to_log = methods_to_log.shift
      else
        # logged :meth1, :meth2, :meth3 without options is valid too
      end
      methods_to_log.each do |method_to_log|
        # method name must be a symbol
        method_to_log = method_to_log.to_sym
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log) do |*args, &block|
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('kl',
                                                                                                        method_to_log)))
                             proxy
                           else
                             proxy = if config_opts.empty?
                                       debug_config
                                     else
                                       DebugLogging::Configuration.new(**debug_config.to_hash.merge(config_opts))
                                     end
                             proxy.register(method_to_log)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('kl', method_to_log),
                                                   proxy)
                             proxy
                           end
            method_return_value = nil
            log_prefix = nil
            invocation_id = nil
            config_proxy.log do
              paydirt = {}
              # TODO: Could make instance variable introspection configurable before or after method execution
              if payload.key?(:instance_variables)
                paydirt.merge!(payload.reject { |k| k == :instance_variables })
                payload[:instance_variables].each do |k|
                  paydirt[k] = instance_variable_get("@#{k}") if instance_variable_defined?("@#{k}")
                end
              else
                paydirt.merge!(payload)
              end
              log_prefix = debug_invocation_to_s(klass: to_s, separator: '.', method_to_log: method_to_log,
                                                 config_proxy: config_proxy)
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
          end
        end
      end
    end
  end
end
