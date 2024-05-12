module DebugLogging
  module LambDart
    class Log < Base
      attr_reader :log_prefix,
        :invocation_id,
        :start_at

      def initialize(...)
        @start_at = Time.now
        super
        @log_prefix = klass.debug_invocation_to_s(
          klass: klass.to_s,
          separator: is_class ? "::" : "#",
          decorated_method:,
          config_proxy:,
        )
        @invocation_id = klass.debug_invocation_id_to_s(args:, config_proxy:)
      end

      def end_timestamp
        klass.debug_time_to_s(Time.now, config_proxy:)
      end

      def benchmarked(tms)
        klass.debug_benchmark_to_s(tms: tms)
      end

      def mark_exit_scope?
        config_proxy.exit_scope_markable? && invocation_id && !invocation_id.empty?
      end

      def bench_scope
        "debug_#{scope_term}_benchmarks".to_sym
      end

      def bench?
        config_proxy.benchmarkable_for?(bench_scope)
      end

      private

      def proxy_ref
        is_class ? "kl" : "ilm"
      end
    end
  end
end
