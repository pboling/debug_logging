# frozen_string_literal: true

module DebugLogging
  module ClassLogger
    def logged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(methods_to_log)
      klass_debug_logged(methods_to_log) do |original_method, method_name|
        (class << self; self; end).class_eval do
          DebugLogging::Util.debug_logged_proc(original_method, method_name, 'kl').call(payload, config_opts)
        end
      end
    end

    def ilogged(*methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(methods_to_log)
      instance_debug_logged(methods_to_log) do |original_method, method_name|
        (class << self; self; end).instance_eval do
          DebugLogging::Util.debug_logged_proc(original_method, method_name, 'kl').call(payload, config_opts)
        end
      end
    end

    private

    def instance_debug_logged(methods_to_log)
      methods_to_log, payload, config_opts = DebugLogging::Util.extract_payload_and_config(methods_to_log)
      instance_method_logger = DebugLogging::InstanceLoggerModulizer.to_mod(methods_to_log: methods_to_log,
                                                                            config: config_opts,
                                                                            payload: payload)
      self.send(:prepend, instance_method_logger)
    end

    def klass_debug_logged(methods_to_log)
      methods_to_log.each do |method_to_log|
        # method name must be a symbol
        method_to_log = method_to_log.to_sym
        original_method = method(method_to_log)
        yield original_method, method_to_log
      end
    end
  end
end
