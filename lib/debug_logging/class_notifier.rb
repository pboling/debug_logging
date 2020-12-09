# frozen_string_literal: true

module DebugLogging
  module ClassNotifier
    def notifies(*methods_to_notify)
      # When opts are present it will always be a new configuration instance per method
      # When opts are not present it will reuse the class' configuration object
      payload = methods_to_notify.last.is_a?(Hash) && methods_to_notify.pop.dup || {}
      config_opts = {}
      DebugLogging::Configuration::CONFIG_KEYS.each {|k| config_opts[k] = payload.delete(k) if payload.key?(k)} unless payload.empty?

      if methods_to_notify.first.is_a?(Array)
        methods_to_notify = methods_to_notify.shift
      else
        # logged :meth1, :meth2, :meth3 without options is valid too
      end
      methods_to_notify.each do |method_to_notify|
        # method name must be a symbol
        method_to_notify = method_to_notify.to_sym
        original_method = method(method_to_notify)
        (class << self; self; end).class_eval do
          define_method(method_to_notify) do |*args, &block|
            config_proxy = if (proxy = instance_variable_get(DebugLogging::Configuration.config_pointer('kn', method_to_notify)))
                             proxy
                           else
                             proxy = if !config_opts.empty?
                                       DebugLogging::Configuration.new(**debug_config.to_hash.merge(config_opts))
                                     else
                                       debug_config
                                     end
                             proxy.register(method_to_notify)
                             instance_variable_set(DebugLogging::Configuration.config_pointer('kn', method_to_notify), proxy)
                             ActiveSupport::Notifications.subscribe(
                               DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify)
                             ) do |*debug_args|
                               proxy.log do
                                 DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*debug_args))
                               end
                             end
                             proxy
                           end
            ActiveSupport::Notifications.instrument(
              DebugLogging::ArgumentPrinter.debug_event_name_to_s(method_to_notify: method_to_notify),
              {
                debug_args: args,
                config_proxy: config_proxy,
                **payload
              }
            ) do
              if args.size == 1 && (harsh = args[0]) && harsh.is_a?(Hash)
                original_method.call(**harsh, &block)
              else
                original_method.call(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end
