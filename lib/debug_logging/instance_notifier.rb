module DebugLogging
  module InstanceNotifier
    class << self
      def extended(base)
        base.include(LambDartable::Note)
      end
    end

    def i_notified(*methods_to_log)
      method_names, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_log,
        payload: nil,
        config: nil,
      )
      instance_method_notifier = DebugLogging::InstanceNotifierModulizer.to_mod(
        methods_to_notify: Array(method_names),
        payload: payload,
        config: config_opts,
      )

      wrapped_in_notifier = Module.new do
        singleton_class.send(:define_method, :included) do |host_class|
          host_class.prepend(instance_method_notifier)
        end
      end

      send(:include, wrapped_in_notifier)
    end
  end
end
