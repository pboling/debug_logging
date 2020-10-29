# frozen_string_literal: true

module DebugLogging
  module ClassNotifier
    def notifies(*methods_to_notify)
      config_proxy = nil

      methods_to_notify.each do |method_to_notify|
        # method name must be a symbol
        payload = method_to_notify.is_a?(Array) && method_to_notify.last.is_a?(Hash) && method_to_notify.pop || {}
        if method_to_notify.is_a?(Array)
          method_to_notify = method_to_notify.first&.to_sym
        else
          method_to_notify.to_sym
        end
        original_method = method(method_to_notify)
        (class << self; self; end).class_eval do
          define_method(method_to_notify) do |*args, &block|
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('k', method_to_notify)))
                             proxy
                           else
                             proxy = if !payload.empty?
                                       Configuration.new(**debug_config.to_hash.merge(payload))
                                     else
                                       debug_config
                                     end
                             proxy.register(method_to_notify)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('k', method_to_notify), proxy)
                             proxy
                           end
            ActiveSupport::Notifications.instrument(
              debug_event_name_to_s(method_to_notify: method_to_notify), { debug_args: args }.merge(payload)
            ) do
              original_method.call(*args, &block)
            end
          end
        end
        ActiveSupport::Notifications.subscribe(
          debug_event_name_to_s(method_to_notify: method_to_notify)
        ) do |*debug_args|
          config_proxy&.log do
            DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*debug_args))
          end
        end
      end
    end
  end
end
