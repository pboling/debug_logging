require "spec_helper"

RSpec.describe DebugLogging do
  include_context "with example classes"

  it "has a version number" do
    expect(DebugLogging::VERSION).not_to be nil
  end

  describe ".debug_log" do
    let(:message) { 'Marty McFly' }
    it "logs when a logger is set" do
      logger = Logger.new(STDOUT)
      simple_klass.debug_logger = logger
      expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
      expect(logger).to receive(:debug).with(message).and_call_original
      output = capture('stdout') do
        simple_klass.debug_log(message)
      end
      expect(output).to match(/Marty McFly/)
    end
    it "does not log not when a logger is not set" do
      simple_klass.debug_logger = nil
      expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
      output = capture('stdout') do
        simple_klass.debug_log(message)
      end
      expect(output).to eq("")
    end
    context 'disabled' do
      describe ".debug_log" do
        before { simple_klass.debug_config.enabled = false }
        let(:message) { 'Marty McFly' }
        it "does not log" do
          logger = Logger.new(STDOUT)
          simple_klass.debug_logger = logger
          expect(simple_klass.debug_config.enabled).to eq(false)
          expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
          expect(logger).to_not receive(:debug)
          output = capture('stdout') do
            simple_klass.debug_log(message)
          end
          expect(output).to eq('')
        end
      end
    end
  end

  describe ".debug_config" do
    it "returns a duplicate of the global configuration with the same logger" do
      expect(simple_klass.debug_config.logger).to eq(DebugLogging.configuration.logger)
    end
  end

  describe "#configuration" do
    it "returns the global configuration with the same logger as the instance config" do
      expect(DebugLogging.configuration.logger).to eq(simple_klass.debug_config.logger)
    end
    it "methods_to_log are not the same array" do
      expect(DebugLogging.configuration.methods_to_log.object_id).to_not eq(simple_klass.debug_config.methods_to_log.object_id)
    end
  end

  describe "#configure" do
    it "allows setting global config in a block" do
      expect do
        DebugLogging.configure do |config|
          config.logger = nil
        end
      end.to_not raise_error
      expect(DebugLogging.configuration.logger).to be_nil
    end
  end

  describe ".debug_logging_configure" do
    let(:message) { 'Marty McFly' }
    it "allows setting config in a block for a class" do
      expect(DebugLogging.configuration.logger).to_not be_nil
      expect do
        simple_klass.debug_logging_configure do |config|
          config.logger = nil
        end
      end.to_not raise_error
      expect(DebugLogging.configuration.logger).to_not be_nil
      expect(simple_klass.debug_config.logger).to be_nil
    end
  end

  describe ".debug_config_reset" do
    let(:message) { 'Marty McFly' }
    it "allows setting config in a block for a class" do
      expect do
        simple_klass.debug_logging_configure do |config|
          config.logger = nil
        end
      end.to_not raise_error
      expect(simple_klass.debug_config.logger).to be_nil
      expect(simple_klass.debug_config_reset).to be_a(DebugLogging::Configuration)
      expect(simple_klass.debug_config.logger).to_not be_nil
    end
  end

  describe ".debug_logger" do
    it "returns the logger" do
      expect(simple_klass.debug_logger).to be_a(Logger)
    end
  end

  describe ".debug_logger=" do
    it "sets the logger" do
      expect(simple_klass.debug_logger).to_not be_nil
      simple_klass.debug_logger = nil
      expect(simple_klass.debug_logger).to be_nil
    end
  end

  describe ".debug_log_level" do
    it "returns the log level" do
      expect(simple_klass.debug_log_level).to eq(:debug)
    end
  end

  describe ".debug_log_level=" do
    it "sets the log level" do
      expect(simple_klass.debug_log_level).to eq(:debug)
      simple_klass.debug_log_level = :info
      expect(simple_klass.debug_log_level).to eq(:info)
    end
  end

  describe ".debug_multiple_last_hashes" do
    it "returns the multiple last hashes setting" do
      expect(simple_klass.debug_multiple_last_hashes).to eq(false)
    end
  end

  describe ".debug_multiple_last_hashes=" do
    it "sets the multiple last hashes setting" do
      expect(simple_klass.debug_multiple_last_hashes).to eq(false)
      simple_klass.debug_multiple_last_hashes = true
      expect(simple_klass.debug_multiple_last_hashes).to eq(true)
    end
  end

  describe ".debug_last_hash_to_s_proc" do
    it "returns the debug_last_hash_to_s_proc value" do
      expect(simple_klass.debug_last_hash_to_s_proc).to eq(nil)
    end
  end

  describe ".debug_last_hash_to_s_proc=" do
    it "sets the multiple last hashes value" do
      expect(simple_klass.debug_last_hash_to_s_proc).to eq(nil)
      simple_klass.debug_last_hash_to_s_proc = ->(a) {a.to_s}
      expect(simple_klass.debug_last_hash_to_s_proc.call(111)).to eq('111')
    end
  end

  describe ".debug_args_max_length" do
    it "returns the debug_args_max_length value" do
      expect(simple_klass.debug_args_max_length).to eq(1_000)
    end
  end

  describe ".debug_args_max_length=" do
    it "sets the multiple last hashes value" do
      expect(simple_klass.debug_args_max_length).to eq(1_000)
      simple_klass.debug_args_max_length = 42
      expect(simple_klass.debug_args_max_length).to eq(42)
    end
  end

  describe ".debug_instance_benchmarks" do
    it "returns the debug_instance_benchmarks value" do
      expect(simple_klass.debug_instance_benchmarks).to eq(false)
    end
  end

  describe ".debug_instance_benchmarks=" do
    it "sets the multiple last hashes value" do
      expect(simple_klass.debug_instance_benchmarks).to eq(false)
      simple_klass.debug_instance_benchmarks = true
      expect(simple_klass.debug_instance_benchmarks).to eq(true)
    end
  end

  describe ".debug_class_benchmarks" do
    it "returns the debug_class_benchmarks value" do
      expect(simple_klass.debug_class_benchmarks).to eq(false)
    end
  end

  describe ".debug_class_benchmarks=" do
    it "sets the debug_class_benchmarks value" do
      expect(simple_klass.debug_class_benchmarks).to eq(false)
      simple_klass.debug_class_benchmarks = true
      expect(simple_klass.debug_class_benchmarks).to eq(true)
    end
  end

  describe ".debug_colorized_chain_for_method" do
    it "returns the debug_colorized_chain_for_method value" do
      expect(simple_klass.debug_colorized_chain_for_method).to eq(false)
    end
  end

  describe ".debug_colorized_chain_for_method=" do
    it "sets the debug_colorized_chain_for_method value" do
      expect(simple_klass.debug_colorized_chain_for_method).to eq(false)
      simple_klass.debug_colorized_chain_for_method = true
      expect(simple_klass.debug_colorized_chain_for_method).to eq(true)
    end
  end

  describe ".debug_colorized_chain_for_class" do
    it "returns the debug_colorized_chain_for_class value" do
      expect(simple_klass.debug_colorized_chain_for_class).to eq(false)
    end
  end

  describe ".debug_colorized_chain_for_class=" do
    it "sets the debug_colorized_chain_for_class value" do
      expect(simple_klass.debug_colorized_chain_for_class).to eq(false)
      simple_klass.debug_colorized_chain_for_class = true
      expect(simple_klass.debug_colorized_chain_for_class).to eq(true)
    end
  end

  describe ".debug_add_invocation_id" do
    it "returns the debug_add_invocation_id value" do
      expect(simple_klass.debug_add_invocation_id).to eq(true)
    end
  end

  describe ".debug_add_invocation_id=" do
    it "sets the debug_add_invocation_id value" do
      expect(simple_klass.debug_add_invocation_id).to eq(true)
      simple_klass.debug_add_invocation_id = false
      expect(simple_klass.debug_add_invocation_id).to eq(false)
    end
  end

  describe ".debug_ellipsis" do
    it "returns the debug_ellipsis value" do
      expect(simple_klass.debug_ellipsis).to eq(DebugLogging::Configuration::DEFAULT_ELLIPSIS)
    end
  end

  describe ".debug_ellipsis=" do
    it "sets the debug_ellipsis value" do
      expect(simple_klass.debug_ellipsis).to eq(DebugLogging::Configuration::DEFAULT_ELLIPSIS)
      simple_klass.debug_ellipsis = 'ROTFLMAO'
      expect(simple_klass.debug_ellipsis).to eq('ROTFLMAO')
    end
  end
end
