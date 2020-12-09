# frozen_string_literal: true

module DebugLogging
  class InstanceLogger < Module
    def initialize(i_methods: nil, config: nil)
      super()
      @config = config
      @instance_methods_to_log = Array(i_methods) if i_methods
    end

    def included(base)
      return unless @instance_methods_to_log

      base.send(:include, ArgumentPrinter)
      instance_method_logger = DebugLogging::InstanceLoggerModulizer.to_mod(methods_to_log: @instance_methods_to_log,
                                                                            config: @config)
      base.send(:prepend, instance_method_logger)
    end
  end
end
