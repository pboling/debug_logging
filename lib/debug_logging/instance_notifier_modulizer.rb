# frozen_string_literal: true

module DebugLogging
  module InstanceNotifierModulizer
    def self.to_mod(methods_to_notify: nil)
      Module.new do
        Array(methods_to_notify).each do |method_to_notify|
          # method name must be a symbol
          payload = method_to_notify.is_a?(Array) && method_to_notify.last.is_a?(Hash) && method_to_notify.pop || {}
          if method_to_notify.is_a?(Array)
            method_to_notify = method_to_notify.first&.to_sym
          else
            method_to_notify.to_sym
          end
          config_proxy = nil
          define_method(method_to_notify) do |*args, &block|
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('i', method_to_notify)))
                             proxy
                           else
                             proxy = if !payload.empty?
                                       Configuration.new(**self.class.debug_config.to_hash.merge(payload))
                                     else
                                       self.class.debug_config
                                     end
                             proxy.register(method_to_notify)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('i', method_to_notify), proxy)
                             proxy
                           end
            if payload.key?(:instance_variables)
              payload[:instance_variables].each do |k|
                payload[k] = instance_variable_get("@#{k}") if instance_variable_get("@#{k}")
              end
              payload.delete(:instance_variables)
            end
            ActiveSupport::Notifications.instrument(
              self.class.debug_event_name_to_s(method_to_notify: method_to_notify), { args: args }.merge(payload)
            ) do
              super(*args, &block)
            end
          end

          ActiveSupport::Notifications.subscribe(/log/) do |*args|
            config_proxy&.log do
              DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*args))
            end
          end
        end
      end
    end
  end
end
