module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log: nil, config: nil)
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          # method name must be a symbol
          define_method(method_to_log.to_sym) do |*args, &block|
            method_return_value = nil
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('i', method_to_log)))
                             proxy
                           else
                             proxy = if config
                                       Configuration.new(**(self.class.debug_config.to_hash.merge(config))) 
                                     else
                                       self.class.debug_config
                                     end
                             proxy.register(method_to_log)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('i', method_to_log), proxy)
                             proxy
                           end
            log_prefix = self.class.debug_invocation_to_s(klass: self.class.to_s, separator: "#", method_to_log: method_to_log, config_proxy: config_proxy)
            invocation_id = self.class.debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
            config_proxy.log do
              signature = self.class.debug_signature_to_s(args: args, config_proxy: config_proxy)
              "#{log_prefix}#{signature}#{invocation_id}"
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
