module DebugLogging
  module InstanceLogger
    def i_logged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_log,
        payload: nil,
        config: nil,
      )
      instance_method_modules =
        Array(methods_to_log).map do |method_to_log|
          DebugLogging::InstanceLoggerModulizer.to_mod(
            methods_to_log: Array(method_to_log),
            payload: payload,
            config: config_opts,
          )
        end
      wrapped_in_logs = Module.new do
        singleton_class.send(:define_method, :included) do |host_class|
          instance_method_modules.each do |mod|
            host_class.prepend(mod)
          end
        end
      end

      send(:include, wrapped_in_logs)
    end
  end
end
