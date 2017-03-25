module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      methods_to_log.each do |method_to_log|
        # method name will always be a symbol
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log) do |*args|
            method_return_value = nil
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if DebugLogging.add_invocation_id && args
            DebugLogging.log "#{self}.#{method_to_log}#{ArgumentPrinter.to_s(args)}#{invocation_id}"
            if DebugLogging.class_benchmarks
              elapsed = Benchmark.realtime do
                method_return_value = original_method.call(*args)
              end
              DebugLogging.log "#{self}.#{method_to_log} completed in #{sprintf("%f", elapsed)}s#{invocation_id}"
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
