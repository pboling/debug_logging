module DebugLogging
  module ClassNotifier
    class << self
      def extended(base)
        base.extend(LambDartable::Note)
      end
    end

    def notified(*methods_to_notify)
      methods_to_notify, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_notify,
        payload: nil,
        config: nil,
      )
      Array(methods_to_notify).each do |decorated_method|
        decorated_method, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: decorated_method,
          payload: payload,
          config: config_opts,
        )
        original_method = method(decorated_method)
        (class << self; self; end).class_eval do
          define_method(decorated_method) do |*args, **kwargs, &block|
            lamb_dart = LambDart::Note.new(
              klass: self,
              method_config_opts:,
              method_payload:,
              args:,
              kwargs:,
              decorated_method:,
            )
            _dl_ld_notify(lamb_dart) do
              _dl_ld_error_handle(lamb_dart) do
                original_method.call(*args, **kwargs, &block)
              end
            end
          end
        end
      end
    end
  end
end
