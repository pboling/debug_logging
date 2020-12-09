# frozen_string_literal: true

module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log: nil, config: nil)
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          payload = (method_to_log.is_a?(Array) && method_to_log.last.is_a?(Hash) && method_to_log.pop.dup) || {}
          config_opts = {}
          unless payload.empty?
            DebugLogging::Configuration::CONFIG_KEYS.each { |k| config_opts[k] = payload.delete(k) if payload.key?(k) }
          end
          # method name must be a symbol
          method_to_log = if method_to_log.is_a?(Array)
                            method_to_log.first&.to_sym
                          else
                            method_to_log.to_sym
                          end
          define_method(method_to_log) do |*args, &block|
            method_return_value = nil
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('ilm',
                                                                                                        method_to_log)))
                             proxy
                           else
                             proxy = if config
                                       Configuration.new(**self.class.debug_config.to_hash.merge(config.merge(config_opts)))
                                     elsif !config_opts.empty?
                                       Configuration.new(**self.class.debug_config.to_hash.merge(config_opts))
                                     else
                                       self.class.debug_config
                                     end
                             proxy.register(method_to_log)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('ilm', method_to_log),
                                                   proxy)
                             proxy
                           end
            log_prefix = self.class.debug_invocation_to_s(klass: self.class.to_s, separator: '#',
                                                          method_to_log: method_to_log, config_proxy: config_proxy)
            invocation_id = self.class.debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
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
              method_return_value = super(*args, &block)
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
