module DebugLogging
  module LambDarts
    module Notify
      def _dl_ld_notify(ld)
        paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: ld.instance, payload: ld.method_payload)
        ActiveSupport::Notifications.instrument(
          DebugLogging::ArgumentPrinter.debug_event_name_to_s(decorated_method: ld.decorated_method),
          debug_args: ld.debug_args,
          config_proxy: ld.config_proxy,
          **paydirt,
        ) do
          yield
        end
      end
    end
  end
end
