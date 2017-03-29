module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      opts = methods_to_log.last.is_a?(Hash) && methods_to_log.pop
      if methods_to_log.first.is_a?(Array)
        methods_to_log = methods_to_log.shift
      else
        # logged :meth1, :meth2, :meth3 is valid
      end
      methods_to_log.each do |method_to_log|
        # method name must be a symbol
        method_to_log = method_to_log.to_sym
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log) do |*args|
            config_proxy =  if opts
                              Configuration.new(**(debug_config.to_hash.merge(opts)))
                            else
                              self
                            end
            method_return_value = nil
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if config_proxy.debug_add_invocation_id
            debug_log "#{self}.#{method_to_log}#{debug_arguments_to_s(args: args, config_proxy: config_proxy)}#{invocation_id}"
            if config_proxy.debug_class_benchmarks
              elapsed = Benchmark.realtime do
                method_return_value = original_method.call(*args)
              end
              debug_log "#{self}.#{method_to_log} completed in #{sprintf("%f", elapsed)}s#{invocation_id}"
            else
              method_return_value = original_method.call(*args)
            end
            method_return_value
          end
        end
      end
    end
  end
end
