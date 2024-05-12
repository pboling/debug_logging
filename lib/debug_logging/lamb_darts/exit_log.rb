module DebugLogging
  module LambDarts
    module ExitLog
      def _dl_ld_exit_log(ld)
        hrv = yield
        return hrv unless ld.mark_exit_scope?

        ld.config_proxy.log do
          "#{ld.end_timestamp}#{ld.log_prefix} completed#{ld.invocation_id}"
        end
        hrv
      end
    end
  end
end
