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
          Array(methods_to_notify).each do |decorated_method|
            decorated_method, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
              method_names: decorated_method,
              payload:,
              config: config_opts,
            )
            define_method(decorated_method) do |*args, **kwargs, &block|
              lamb_dart = LambDart::Note.new(
                instance: self,
                method_config_opts:,
                method_payload:,
                args:,
                kwargs:,
                decorated_method:,
              )
              _dl_ld_notify(lamb_dart) do
                _dl_ld_error_handle(lamb_dart) do
                  super(*args, **kwargs, &block)
                end
              end
            end
          end
        end
      end
    end
  end
end
