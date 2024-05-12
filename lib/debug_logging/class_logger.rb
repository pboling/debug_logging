module DebugLogging
  module ClassLogger
    class << self
      def extended(base)
        base.extend(LambDartable)
      end
    end

    def logged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(
        method_names: methods_to_log,
        payload: nil,
        config: nil,
      )
      Array(methods_to_log).each do |method_to_log|
        method_to_log, method_payload, method_config_opts = DebugLogging::Util.extract_payload_and_config(
          method_names: method_to_log,
          payload: payload,
          config: config_opts,
        )
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log) do |*args, **kwargs, &block|
            lamb_dart = LambDart.new(
              klass: self,
              method_config_opts:,
              method_payload:,
              args:,
              kwargs:,
              method_to_log:,
            )
            real_mccoy = ->() {
              original_method.call(*args, **kwargs, &block)
            }
            _dl_ld_enter_log(lamb_dart) do
              _dl_ld_error_handle(lamb_dart) do
                return _dl_ld_benchmarked(lamb_dart) { real_mccoy.call } if lamb_dart.bench?

                _dl_ld_exit_log(lamb_dart) { real_mccoy.call }
              end
            end
          end
        end
      end
    end
  end
end
