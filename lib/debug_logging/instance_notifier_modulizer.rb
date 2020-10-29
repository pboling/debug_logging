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
            invocation_id = self.class.debug_invocation_id_to_s(args: args, config_proxy: config_proxy)
            debug_event_name = self.class.debug_event_name_to_s(method_to_notify: method_to_notify, separator: '#', invocation_id: invocation_id)
            ActiveSupport::Notifications.subscribe(debug_event_name) do |*debug_args|
              config_proxy&.log do
                DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*debug_args))
              end
            end
            paydirt = { debug_args: args }
            if payload.key?(:instance_variables)
              payload[:instance_variables].each do |k|
                paydirt[k] = instance_variable_get("@#{k}") if instance_variable_get("@#{k}")
              end
            end
            paydirt.merge!(payload.reject { |k| k == :instance_variables })
            ActiveSupport::Notifications.instrument(debug_event_name, paydirt) do
              super(*args, &block)
            end
          end
        end
      end
    end
  end
end
