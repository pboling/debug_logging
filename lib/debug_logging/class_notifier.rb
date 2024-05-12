module DebugLogging
  module ClassNotifier
    def notified(*methods_to_notify)
      methods_to_notify, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_notify,
        payload: nil,
        config: nil,
      )
      Array(methods_to_notify).each do |method_to_notify|
        method_to_notify, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: method_to_notify,
          payload: payload,
          config: config_opts,
        )
        original_method = method(method_to_notify)
        (class << self; self; end).class_eval do
          define_method(method_to_notify) do |*args, **kwargs, &block|
            config_proxy = DebugLogging::Util.config_proxy_finder(
              scope: self,
              config_opts: method_config_opts,
              method_name: method_to_notify,
              proxy_ref: "kn",
            ) do |proxy|
              ActiveSupport::Notifications.subscribe(
                DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify),
              ) do |*debug_args|
                proxy.log do
                  DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*debug_args))
                end
              end
            end
            paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: self, payload: method_payload)
            ActiveSupport::Notifications.instrument(
              DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify),
              {
                debug_args: kwargs.empty? ? args : args + [kwargs],
                config_proxy: config_proxy,
                **paydirt,
              },
            ) do
              original_method.call(*args, **kwargs, &block)
            rescue StandardError => e
              if config_proxy.error_handler_proc
                config_proxy.error_handler_proc.call(config_proxy, e, self, method_to_notify, *args, **kwargs)
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
