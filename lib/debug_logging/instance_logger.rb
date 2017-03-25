module DebugLogging
  class InstanceLogger < Module
    def initialize(i_methods: nil)
      @instance_methods_to_log = Array(i_methods) if i_methods
    end
    def included(base)
      if @instance_methods_to_log
        base.send(:include, ArgumentPrinter)
        instance_method_logger = DebugLogging::InstanceLoggerModulizer.to_mod(@instance_methods_to_log)
        base.send(:prepend, instance_method_logger)
      end
    end
  end
end
