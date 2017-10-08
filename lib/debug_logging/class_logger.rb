module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      # When opts are present it will always be a new configuration instance per method
      # When opts are not present it will reuse the class' configuration object
      opts = methods_to_log.last.is_a?(Hash) && methods_to_log.pop
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
            config_proxy = if (proxy = instance_variable_get("@debug_config_proxy_for_k_#{method_to_log}".to_sym))
                             proxy
                           else
                             proxy = if opts
                                       Configuration.new(**(debug_config.to_hash.merge(opts)))
                                     else
                                       debug_config
                                     end
                             proxy.register(method_to_log)
                             instance_variable_set("@debug_config_proxy_for_k_#{method_to_log}".to_sym, proxy)
                             proxy
                           end
            method_return_value = nil
            log_prefix = nil
            invocation_id = nil
            config_proxy.log do
              log_prefix = debug_invocation_to_s(klass: to_s, separator: ".", method_to_log: method_to_log, config_proxy: config_proxy)
              invocation_id = debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
              signature = debug_signature_to_s(args: args, config_proxy: config_proxy)
              "#{log_prefix}#{signature}#{invocation_id}"
            end
            if config_proxy.benchmarkable_for?(:debug_class_benchmarks)
              tms = Benchmark.measure do
                method_return_value = original_method.call(*args, &block)
              end
              config_proxy.log do
                "#{log_prefix} #{debug_benchmark_to_s(tms: tms)}#{invocation_id}"
              end
            else
              method_return_value = original_method.call(*args, &block)
            end
            method_return_value
          end
        end
      end
    end
  end
end
