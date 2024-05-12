module DebugLogging
  module LambDarts
    module Benchmarked
      def _dl_ld_benchmarked(ld)
        brv = nil
        # Benchmarking as close to the real mccoy as possible,
        #   so as to not pollute performance tracking with the effects of debug_logging,
        #   which may be removed once data has been gathered, or turned off.
        tms = Benchmark.measure do
          brv = yield
        end
        ld.config_proxy.log do
          "#{ld.end_timestamp}#{ld.log_prefix} #{ld.benchmarked(tms)}#{ld.invocation_id}"
        end
        brv
      end
    end
  end
end
