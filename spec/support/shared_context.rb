RSpec.shared_context "with example classes" do
  after do
    DebugLogging.debug_logging_configuration = DebugLogging::Configuration.new
  end

  let(:logger) { double("logger") }

  let(:simple_klass) {
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
    end
  }

  let(:complete_logged_klass) {
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `logged` class method
      extend DebugLogging::ClassLogger
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: [:i, :i_with_ssplat, :i_with_dsplat])
      logged def self.k; 10; end
      def self.k_with_ssplat(*args); 20; end
      def self.k_with_dsplat(**args); 30; end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_without_log; 0; end
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }

  let(:singleton_logged_klass) {
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Needs to be at the top of the class
      extend DebugLogging::ClassLogger
      logged def self.k; 10; end
      def self.k_with_ssplat(*args); 20; end
      def self.k_with_dsplat(**args); 30; end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_without_log; 0; end
    end
  }

  let(:instance_logged_klass_explicit) {
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: [:i, :i_with_ssplat, :i_with_dsplat])
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }

  let(:instance_logged_klass_dynamic) {
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when dynamic
      include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }
end
