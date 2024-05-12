module DebugLogging
  module LambDarts
    module EnterLog
      def _dl_ld_enter_log(ld)
        start_timestamp = ld.klass.debug_time_to_s(ld.start_at, config_proxy: ld.config_proxy)
        ld.config_proxy.log do
          paydirt = DebugLogging::Util.payload_instance_variable_hydration(scope: ld.instance, payload: ld.method_payload)
          signature = ld.klass.debug_signature_to_s(args: ld.args, kwargs: ld.kwargs, config_proxy: ld.config_proxy)
          paymud = ld.instance.debug_payload_to_s(payload: paydirt, config_proxy: ld.config_proxy)
          "#{start_timestamp}#{ld.log_prefix}#{signature}#{ld.invocation_id} debug: #{paymud}"
        end
        yield
      end
    end
  end
end
