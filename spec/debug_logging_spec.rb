RSpec.describe DebugLogging do
  include_context "with example classes"

  describe ".debug_log" do
    let(:message) { "Marty McFly" }

    it "logs when a logger is set" do
      logger = Logger.new($stdout)
      simple_klass.debug_logger = logger
      expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
      expect(logger).to receive(:debug).with(message).and_call_original
      output = capture("stdout") do
        simple_klass.debug_log(message)
      end
      expect(output).to match(/Marty McFly/)
    end

    it "does not log not when a logger is not set" do
      simple_klass.debug_logger = nil
      expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
      output = capture("stdout") do
        simple_klass.debug_log(message)
      end
      expect(output).to eq("")
    end

    context "disabled" do
      describe ".debug_log" do
        before { simple_klass.debug_config.enabled = false }

        let(:message) { "Marty McFly" }

        it "does not log" do
          logger = Logger.new($stdout)
          simple_klass.debug_logger = logger
          expect(simple_klass.debug_config.enabled).to eq(false)
          expect(simple_klass.debug_config).to receive(:log).with(message).and_call_original
          expect(logger).not_to receive(:debug)
          output = capture("stdout") do
            simple_klass.debug_log(message)
          end
          expect(output).to eq("")
        end
      end
    end
  end

  describe ".debug_config" do
    it "returns a duplicate of the global configuration with the same logger" do
      expect(simple_klass.debug_config.logger).to eq(described_class.configuration.logger)
    end
  end

  describe "#configuration" do
    it "returns the global configuration with the same logger as the instance config" do
      expect(described_class.configuration.logger).to eq(simple_klass.debug_config.logger)
    end

    it "methods_to_log are not the same array" do
      expect(described_class.configuration.methods_to_log.object_id).not_to eq(simple_klass.debug_config.methods_to_log.object_id)
    end
  end

  describe "#configure" do
    it "allows setting global config in a block" do
      expect do
        described_class.configure do |config|
          config.logger = nil
        end
      end.not_to raise_error
      expect(described_class.configuration.logger).to be_nil
    end
  end

  describe ".debug_logging_configure" do
    let(:message) { "Marty McFly" }

    it "allows setting config in a block for a class" do
      expect(described_class.configuration.logger).not_to be_nil
      expect do
        simple_klass.debug_logging_configure do |config|
          config.logger = nil
        end
      end.not_to raise_error
      expect(described_class.configuration.logger).not_to be_nil
      expect(simple_klass.debug_config.logger).to be_nil
    end
  end

  describe ".debug_config_reset" do
    let(:message) { "Marty McFly" }

    it "allows setting config in a block for a class" do
      expect do
        simple_klass.debug_logging_configure do |config|
          config.logger = nil
        end
      end.not_to raise_error
      expect(simple_klass.debug_config.logger).to be_nil
      expect(simple_klass.debug_config_reset).to be_a(described_class::Configuration)
      expect(simple_klass.debug_config.logger).not_to be_nil
    end
  end

  describe ".debug_logger" do
    it "returns the logger" do
      expect(simple_klass.debug_logger).to be_a(Logger)
    end
  end

  describe ".debug_logger=" do
    it "sets the logger" do
      expect(simple_klass.debug_logger).not_to be_nil
      simple_klass.debug_logger = nil
      expect(simple_klass.debug_logger).to be_nil
    end
  end

  describe ".debug_log_level" do
    it "returns the log level" do
      expect(simple_klass.debug_log_level).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:log_level])
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
      expect(simple_klass.debug_multiple_last_hashes).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:multiple_last_hashes])
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
      expect(simple_klass.debug_last_hash_to_s_proc).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:last_hash_to_s_proc])
    end
  end

  describe ".debug_last_hash_to_s_proc=" do
    it "sets the multiple last hashes value" do
      expect(simple_klass.debug_last_hash_to_s_proc).to eq(nil)
      simple_klass.debug_last_hash_to_s_proc = ->(a) { a.to_s }
      expect(simple_klass.debug_last_hash_to_s_proc.call(111)).to eq("111")
    end
  end

  describe ".debug_args_to_s_proc" do
    it "returns the debug_args_to_s_proc value" do
      expect(simple_klass.debug_args_to_s_proc).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:args_to_s_proc])
    end
  end

  describe ".debug_args_to_s_proc=" do
    it "sets the args proc value" do
      expect(simple_klass.debug_last_hash_to_s_proc).to eq(nil)
      simple_klass.debug_args_to_s_proc = ->(a) { a.to_s[0..3] }
      expect(simple_klass.debug_args_to_s_proc.call(11_114_444)).to eq("1111")
    end
  end

  describe ".debug_args_max_length" do
    it "returns the debug_args_max_length value" do
      expect(simple_klass.debug_args_max_length).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:args_max_length])
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
      expect(simple_klass.debug_instance_benchmarks).to eq(described_class::Constants::CONFIG_READERS_DEFAULTS[:instance_benchmarks])
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
      expect(simple_klass.debug_class_benchmarks).to eq(described_class::Constants::CONFIG_READERS_DEFAULTS[:class_benchmarks])
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
      expect(simple_klass.debug_colorized_chain_for_method).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:colorized_chain_for_method])
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
      expect(simple_klass.debug_colorized_chain_for_class).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:colorized_chain_for_class])
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
      expect(simple_klass.debug_add_invocation_id).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:add_invocation_id])
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
      expect(simple_klass.debug_ellipsis).to eq(described_class::Configuration::DEFAULT_ELLIPSIS)
    end
  end

  describe ".debug_ellipsis=" do
    it "sets the debug_ellipsis value" do
      expect(simple_klass.debug_ellipsis).to eq(described_class::Configuration::DEFAULT_ELLIPSIS)
      simple_klass.debug_ellipsis = "ROTFLMAO"
      expect(simple_klass.debug_ellipsis).to eq("ROTFLMAO")
    end
  end

  describe ".debug_mark_scope_exit" do
    it "returns the debug_mark_scope_exit value" do
      expect(simple_klass.debug_mark_scope_exit).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:mark_scope_exit])
    end
  end

  describe ".debug_mark_scope_exit=" do
    it "sets the debug_mark_scope_exit value" do
      expect(simple_klass.debug_mark_scope_exit).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:mark_scope_exit])
      simple_klass.debug_mark_scope_exit = !described_class::Constants::CONFIG_ATTRS_DEFAULTS[:mark_scope_exit]
      expect(simple_klass.debug_mark_scope_exit).to eq(!described_class::Constants::CONFIG_ATTRS_DEFAULTS[:mark_scope_exit])
    end
  end

  describe ".debug_add_payload" do
    it "returns the debug_add_payload value" do
      expect(simple_klass.debug_add_payload).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:add_payload])
    end
  end

  describe ".debug_add_payload=" do
    it "sets the debug_add_payload value" do
      expect(simple_klass.debug_add_payload).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:add_payload])
      simple_klass.debug_add_payload = ->(a) { a.to_s[0..3] }
      expect(simple_klass.debug_add_payload).to be_a(Proc)
    end
  end

  describe ".debug_payload_max_length" do
    it "returns the debug_payload_max_length value" do
      expect(simple_klass.debug_payload_max_length).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:payload_max_length])
    end
  end

  describe ".debug_payload_max_length=" do
    it "sets the debug_payload_max_length value" do
      expect(simple_klass.debug_payload_max_length).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:payload_max_length])
      simple_klass.debug_payload_max_length = 555
      expect(simple_klass.debug_payload_max_length).to eq(555)
    end
  end

  describe ".debug_error_handler_proc" do
    it "returns the debug_error_handler_proc value" do
      expect(simple_klass.debug_error_handler_proc).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:error_handler_proc])
    end
  end

  describe ".debug_error_handler_proc=" do
    it "sets the debug_error_handler_proc value" do
      expect(simple_klass.debug_error_handler_proc).to eq(described_class::Constants::CONFIG_ATTRS_DEFAULTS[:error_handler_proc])
      simple_klass.debug_error_handler_proc = ->(a) { a.to_s[0..3] }
      expect(simple_klass.debug_error_handler_proc).to be_a(Proc)
    end
  end
end
