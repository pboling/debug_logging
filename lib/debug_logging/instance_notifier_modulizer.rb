module DebugLogging
  module InstanceNotifierModulizer
    class << self
      def to_mod(methods_to_notify: nil, payload: nil, config: nil)
        Module.new do
          methods_to_notify, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
            method_names: Array(methods_to_notify),
            payload:,
            config:,
          )
          Array(methods_to_notify).each do |method_to_notify|
            method_to_notify, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
              method_names: method_to_notify,
              payload:,
              config: config_opts,
            )
            define_method(method_to_notify) do |*args, **kwargs, &block|
              config_proxy = DebugLogging::Util.config_proxy_finder(
                scope: self.class,
                config_opts: method_config_opts,
                method_name: method_to_notify,
                proxy_ref: "inm",
              ) do |config_proxy|
                ActiveSupport::Notifications.subscribe(
                  DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify:),
                ) do |*subscribe_args|
                  config_proxy&.log do
                    DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*subscribe_args))
                  end
                end
              end
              paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: self, payload: method_payload)
              ActiveSupport::Notifications.instrument(
                DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify:),
                debug_args: kwargs.empty? ? args : args + [kwargs],
                config_proxy: config_proxy,
                **paydirt,
              ) do
                super(*args, **kwargs, &block)
              rescue StandardError => e
                if config_proxy.error_handler_proc
                  config_proxy.error_handler_proc.call(config_proxy, e, self, method_to_notify, args, kwargs)
                else
                  raise e
                end
              end
            end
          end
        end
      end
    end
  end
end
