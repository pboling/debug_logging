RSpec.describe DebugLogging::ArgumentPrinter do
  let(:myklass) do
    Class.new do
      include DebugLogging::ArgumentPrinter
    end
  end
  let(:instance) { myklass.new }

  describe "#debug_benchmark_to_s" do
    subject(:debug_benchmark_to_s) { instance.debug_benchmark_to_s(tms: tms) }

    let(:tms) { double("tms", real: 42, total: 543) }

    it "prints" do
      expect(debug_benchmark_to_s).to start_with("completed in ")
    end
  end

  describe "#debug_invocation_id_to_s" do
    subject(:debug_invocation_id_to_s) { instance.debug_invocation_id_to_s(args: args, config_proxy: config_proxy) }

    let(:args) { false }
    let(:config_proxy) { false }

    it "prints" do
      expect(debug_invocation_id_to_s).to eq("")
    end
  end

  describe "#debug_time_to_s" do
    subject(:debug_time_to_s) { instance.debug_time_to_s(time_or_monotonic) }

    context "when float" do
      let(:time_or_monotonic) { 0.1 }
      it "prints" do
        expect(debug_time_to_s).to match(/\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
      end
    end

    context "when time" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23) }
      it "prints" do
        expect(debug_time_to_s).to match(/\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
      end
    end

    context "when datetime" do
      let(:time_or_monotonic) { DateTime.new(2019, 8, 10, 4, 10, 9)  }
      it "prints" do
        expect(debug_time_to_s).to match(/\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
      end
    end

    context "when string" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23).to_s }
      it "prints" do
        expect(debug_time_to_s).to match(/\d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}/)
      end
    end

    context "when otherwise" do
      let(:time_or_monotonic) { :time }
      it "prints" do
        expect(debug_time_to_s).to match(/time/)
      end
    end
  end

  describe "#debug_invocation_to_s" do
    subject(:debug_invocation_to_s) { instance.debug_invocation_to_s(klass: nil, separator: nil, method_to_log: nil, config_proxy: config_proxy) }

    let(:config_proxy) { false }

    it "prints" do
      expect(debug_invocation_to_s).to eq("")
    end
  end

  describe "#debug_signature_to_s" do
    subject(:debug_signature_to_s) { instance.debug_signature_to_s(args: nil, config_proxy: nil) }

    let(:args) { false }
    let(:config_proxy) { false }

    it "prints" do
      expect(debug_signature_to_s).to eq("")
    end
  end

  describe "#debug_payload_to_s" do
    subject(:debug_payload_to_s) { instance.debug_payload_to_s(payload: payload, config_proxy: config_proxy) }

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
        double(
          "config_proxy",
          debug_add_payload: ->(args) { "pppaaayyylllo #{args}" },
          payload_max_length: payload_max_length,
          debug_ellipsis: "^^^"
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
        double(
          "config_proxy",
          debug_add_payload: ->(args) { "pppaaayyy #{args}" },
          payload_max_length: payload_max_length,
          debug_ellipsis: "^^^"
        )
      }

      it "prints" do
        expect(debug_payload_to_s).to eq("pppaaayyy []")
      end
    end
  end
end
