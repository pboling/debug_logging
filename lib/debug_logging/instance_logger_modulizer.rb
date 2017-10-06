module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log: nil, config: nil)
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          # method name must be a symbol

          define_method(method_to_log.to_sym) do |*args, &block|
            method_return_value = nil
            config_proxy = if (proxy = instance_variable_get("@debug_config_proxy_for_#{method_to_log}".to_sym))
                             proxy
                           else
                             proxy = if config
                                       Configuration.new(**(self.class.debug_config.to_hash.merge(config))) 
                                     else
                                       self.class
                                     end
                             instance_variable_set("@debug_config_proxy_for_#{method_to_log}".to_sym, proxy)
                             proxy
                           end
            # TODO: Put all the logic into a logger block, so it will never be computed at runtime if the log level is too high
            log_prefix = self.class.debug_invocation_to_s(klass: self.class.to_s, separator: "#", method_to_log: method_to_log, config_proxy: config_proxy)
            signature = self.class.debug_signature_to_s(args: args, config_proxy: config_proxy)
            invocation_id = self.class.debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
            self.class.debug_log("#{log_prefix}#{signature}#{invocation_id}", config_proxy)
            if config_proxy.debug_instance_benchmarks
              tms = Benchmark.measure do
                method_return_value = super(*args, &block)
              end
              self.class.debug_log("#{log_prefix} #{self.class.debug_benchmark_to_s(tms: tms)}#{invocation_id}", config_proxy)
            else
              method_return_value = super(*args, &block)
            end
            method_return_value
          end
        end
      end
    end
  end
end
