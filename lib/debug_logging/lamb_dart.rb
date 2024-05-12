module DebugLogging
  class LambDart
    extend Forwardable

    attr_reader :instance, # For ClassLogger, this will be the same as klass
      :klass,
      :config_proxy,
      :method_payload,
      :args,
      :kwargs,
      :method_to_log,
      :log_prefix,
      :invocation_id,
      :start_at,
      :scope_term

    def_delegator :@config_proxy, :error_handler_proc

    def initialize(instance: nil, klass: nil, method_config_opts:, method_payload:, args:, kwargs:, method_to_log:)
      @start_at = Time.now
      @instance = instance || klass
      @klass = klass || instance.class
      @method_payload = method_payload
      @args = args
      @kwargs = kwargs
      @method_to_log = method_to_log
      is_class = (self.klass == self.instance)
      @scope_term = is_class ? "class" : "instance"
      @config_proxy = DebugLogging::Util.config_proxy_finder(
        scope: self.klass,
        config_opts: method_config_opts,
        method_name: self.method_to_log,
        proxy_ref: is_class ? "kl" : "ilm",
      )
      @log_prefix = self.klass.debug_invocation_to_s(
        klass: self.klass.to_s,
        separator: is_class ? "::" : "#",
        method_to_log: self.method_to_log,
        config_proxy: config_proxy,
      )
      @invocation_id = self.klass.debug_invocation_id_to_s(args: self.args, config_proxy: config_proxy)
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
  end
end
