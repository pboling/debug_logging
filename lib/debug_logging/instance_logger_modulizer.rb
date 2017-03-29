module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log: nil, config_proxy: nil)
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          # method name must be a symbol
          define_method(method_to_log.to_sym) do |*args, &block|
            config_proxy = if config_proxy.is_a?(Hash)
                             Configuration.new(**(self.class.debug_config.to_hash.merge(config_proxy)))
                           else
                             self.class
                           end
            method_return_value = nil
            log_prefix = "#{self.class}##{method_to_log}"
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if config_proxy.debug_add_invocation_id && args
            self.class.debug_log "#{log_prefix}#{self.class.debug_arguments_to_s(args: args, config_proxy: config_proxy)}#{invocation_id}"
            if config_proxy.debug_instance_benchmarks
              elapsed = Benchmark.realtime do
                method_return_value = super(*args, &block)
              end
              self.class.debug_log "#{log_prefix} completed in #{sprintf("%f", elapsed)}s#{invocation_id}"
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
