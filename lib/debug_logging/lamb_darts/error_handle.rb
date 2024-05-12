module DebugLogging
  module LambDarts
    module ErrorHandle
      def _dl_ld_error_handle(ld)
        if ld.config_proxy.error_handler_proc
          begin
            yield
          rescue StandardError => e
            if ld.error_handler_proc
              ld.error_handler_proc.call(
                ld.config_proxy,
                e,
                self,
                ld.decorated_method,
                *ld.args,
                **ld.kwargs,
              )
            else
              raise e
            end
          end
        else
          yield
        end
      end
    end
  end
end
