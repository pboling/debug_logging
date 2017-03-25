module DebugLogging
  module InstanceLoggerModulizer
    def self.to_mod(methods_to_log = [])
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          # method name must be a symbol
          define_method(method_to_log.to_sym) do |*args, &block|
            method_return_value = nil
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if self.class.debug_add_invocation_id && args
            self.class.debug_log "#{self.class}##{method_to_log}#{self.class.debug_arguments_to_s(args)}#{invocation_id}"
            if self.class.debug_instance_benchmarks
              elapsed = Benchmark.realtime do
                method_return_value = super(*args, &block)
              end
              self.class.debug_log "#{self.class}##{method_to_log} completed in #{sprintf("%f", elapsed)}s#{invocation_id}"
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
