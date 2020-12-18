# frozen_string_literal: true

module DebugLogging
  module InstanceNotifierModulizer
    def self.to_mod(methods_to_notify: nil, payload: nil, config: nil)
      Module.new do
        methods_to_notify, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: Array(methods_to_notify),
          payload: payload,
          config: config
        )
        Array(methods_to_notify).each do |method_to_notify|
          method_to_notify, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
            method_names: method_to_notify,
            payload: payload,
            config: config_opts
          )
          define_method(method_to_notify) do |*args, &block|
            config_proxy = DebugLogging::Util.config_proxy_finder(
              scope: self.class,
              config_opts: method_config_opts,
              method_name: method_to_notify,
              proxy_ref: 'inm'
            ) do |config_proxy|
              ActiveSupport::Notifications.subscribe(
                DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify)
              ) do |*args|
                config_proxy&.log do
                  DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*args))
                end
              end
            end
            paydirt = DebugLogging::Util.payload_instance_vaiable_hydration(scope: self, payload: method_payload)
            ActiveSupport::Notifications.instrument(
              DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify),
              debug_args: args,
              config_proxy: config_proxy,
              **paydirt
            ) do
              super(*args, &block)
            end
          end
        end
      end
    end
  end
end
