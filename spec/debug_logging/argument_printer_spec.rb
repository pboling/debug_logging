RSpec.describe DebugLogging::ArgumentPrinter do
  let(:myklass) do
    Class.new do
      include DebugLogging::ArgumentPrinter
    end
  end
  let(:instance) { myklass.new }
  let(:time_format_regex) { /\d{4,}\d{2}\d{2} \d{2}:\d{2}:\d{2}/ }
  let(:event_time_format_regex) { /\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/ }

  describe "#debug_benchmark_to_s" do
    subject(:debug_benchmark_to_s) { instance.debug_benchmark_to_s(tms:) }

    let(:tms) { double("tms", real: 42, total: 543) }

    it "prints" do
      expect(debug_benchmark_to_s).to start_with("completed in ")
    end
  end

  describe "#debug_invocation_id_to_s" do
    subject(:debug_invocation_id_to_s) { instance.debug_invocation_id_to_s(args: args, config_proxy:) }

    let(:args) { false }
    let(:config_proxy) { false }

    it "prints" do
      expect(debug_invocation_id_to_s).to eq("")
    end
  end

  describe "#debug_time_to_s" do
    subject(:debug_time_to_s) { instance.debug_time_to_s(time_or_monotonic, config_proxy:) }

    let(:config_proxy) {
      instance_double(
        DebugLogging::Configuration,
        debug_add_timestamp: true,
        debug_time_formatter_proc: DebugLogging::Constants::DEFAULT_TIME_FORMATTER,
      )
    }

    context "when no config_proxy" do
      let(:config_proxy) { nil }

      let(:time_or_monotonic) { 0.1 }

      it "prints" do
        expect(debug_time_to_s).to eq("")
      end
    end

    context "when float" do
      let(:time_or_monotonic) { 0.1 }

      it "prints" do
        expect(debug_time_to_s).to match(time_format_regex)
      end
    end

    context "when time" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23) }

      it "prints" do
        expect(debug_time_to_s).to match(time_format_regex)
      end
    end

    context "when datetime" do
      let(:time_or_monotonic) { DateTime.new(2019, 8, 10, 4, 10, 9) }

      it "prints" do
        expect(debug_time_to_s).to match(time_format_regex)
      end
    end

    context "when string" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23).to_s }

      it "prints" do
        expect(debug_time_to_s).to match(time_format_regex)
      end
    end

    context "when otherwise" do
      let(:time_or_monotonic) { :time }

      it "prints" do
        expect(debug_time_to_s).to match(time_format_regex)
      end
    end
  end

  describe "#debug_event_time_to_s" do
    subject(:debug_event_time_to_s) { instance.debug_event_time_to_s(time_or_monotonic) }

    context "when float" do
      let(:time_or_monotonic) { 0.1 }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end

    context "when time" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23) }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end

    context "when datetime" do
      let(:time_or_monotonic) { DateTime.new(2019, 8, 10, 4, 10, 9) }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end

    context "when string" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23).to_s }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end

    context "when empty" do
      let(:time_or_monotonic) { [] }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end

    context "when otherwise" do
      let(:time_or_monotonic) { :time }

      it "prints" do
        expect(debug_event_time_to_s).to match(event_time_format_regex)
      end
    end
  end

  describe "#debug_invocation_to_s" do
    subject(:debug_invocation_to_s) { instance.debug_invocation_to_s(klass:, separator:, method_to_log:, config_proxy:) }

    let(:klass) { nil }
    let(:separator) { nil }
    let(:method_to_log) { nil }
    let(:config_proxy) { false }

    it "prints" do
      expect(debug_invocation_to_s).to eq("")
    end

    context "when config_proxy" do
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_colorized_chain_for_class: ->(str) { str.blue },
          debug_colorized_chain_for_method: ->(str) { str.blue },
        )
      }
      let(:klass) { ParentSingletonClass }
      let(:separator) { "^.^" }
      let(:method_to_log) { :shoe_fly }

      it "prints" do
        expect(debug_invocation_to_s).to eq("\e[0;34;49mParentSingletonClass\e[0m^.^\e[0;34;49mshoe_fly\e[0m")
      end
    end
  end

  describe "#debug_signature_to_s" do
    subject(:debug_signature_to_s) { instance.debug_signature_to_s(args:, config_proxy:) }

    let(:args) { nil }
    let(:config_proxy) { nil }

    it "prints" do
      expect(debug_signature_to_s).to eq("")
    end

    context "when config_proxy" do
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_last_hash_to_s_proc: ->(hash) { hash.keys.to_s },
          debug_args_to_s_proc: ->(args) { args.to_s[0..9] },
          debug_args_max_length: 10,
          debug_multiple_last_hashes: false,
          debug_last_hash_max_length: 15,
        )
      }
      let(:args) { [1, 2, 3, {zz: :top}] }

      it "prints" do
        expect(debug_signature_to_s).to eq("([1, 2, 3], [:zz])")
      end
    end

    context "when ellipsis" do
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_last_hash_to_s_proc: ->(hash) { hash.keys.to_s },
          debug_args_to_s_proc: ->(args) { args.to_s[0..9] },
          debug_args_max_length: 3,
          debug_multiple_last_hashes: false,
          debug_last_hash_max_length: 5,
          debug_ellipsis: ".•.",
        )
      }
      let(:args) { [1, 2, 3, {zz_yy_xx: :top}] }

      it "prints" do
        expect(debug_signature_to_s).to eq("([1, .•., [:zz_y.•.)")
      end
    end

    context "when multiple last hashes" do
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_last_hash_to_s_proc: ->(hash) { hash.keys.to_s },
          debug_args_to_s_proc: ->(args) { args.to_s[0..9] },
          debug_args_max_length: 10,
          debug_multiple_last_hashes: true,
          debug_last_hash_max_length: 15,
          debug_ellipsis: "...",
        )
      }
      let(:args) { [1, 2, 3, {zz: :top}, {def: :leopard}] }

      it "prints" do
        expect(debug_signature_to_s).to eq("([1, 2, 3], [:zz], [:def])")
      end
    end

    context "when multiple last hashes and ellipsis" do
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_last_hash_to_s_proc: ->(hash) { hash.keys.to_s },
          debug_args_to_s_proc: ->(args) { args.to_s[0..9] },
          debug_args_max_length: 5,
          debug_multiple_last_hashes: true,
          debug_last_hash_max_length: 7,
          debug_ellipsis: ".~.",
        )
      }
      let(:args) { [1, 2, 3, {zz: :top}, {def_leopard_pours_sugar: :on_me}] }

      it "prints" do
        expect(debug_signature_to_s).to eq("([1, 2,.~., [:zz], [:def_le.~.)")
      end
    end
  end

  describe "#debug_payload_to_s" do
    subject(:debug_payload_to_s) { instance.debug_payload_to_s(payload:, config_proxy:) }

    context "no payload, no config" do
      let(:payload) { false }
      let(:config_proxy) { false }

      it "prints" do
        expect(debug_payload_to_s).to eq("")
      end
    end

    context "with payload, with config debug_add_payload: proc, with ellipsis" do
      let(:payload) { [] }
      let(:payload_max_length) { 15 }
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_add_payload: ->(args) { "pppaaayyylllo #{args}" },
          debug_payload_max_length: payload_max_length,
          debug_ellipsis: "^^^",
        )
      }

      it "prints" do
        expect(debug_payload_to_s).to eq("pppaaayyylllo []^^^")
      end
    end

    context "with payload, with config debug_add_payload: proc, no ellipsis" do
      let(:payload) { [] }
      let(:payload_max_length) { 15 }
      let(:config_proxy) {
        instance_double(
          DebugLogging::Configuration,
          debug_add_payload: ->(args) { "pppaaayyy #{args}" },
          debug_payload_max_length: payload_max_length,
          debug_ellipsis: "^^^",
        )
      }

      it "prints" do
        expect(debug_payload_to_s).to eq("pppaaayyy []")
      end
    end
  end
end
