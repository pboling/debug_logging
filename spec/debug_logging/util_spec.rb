RSpec.describe DebugLogging::Util do
  include_context "with example classes"

  context "an instance notified klass with string logged methods" do
    before do
      @events = []
      @subscriber = ActiveSupport::Notifications.subscribe(/log/) do |*args|
        @events << ActiveSupport::Notifications::Event.new(*args)
      end
    end

    it "logs" do
      output = capture("stdout") do
        instance_notified_klass_string_logged_imethods.new.i
        instance_notified_klass_string_logged_imethods.new.i_with_ssplat
        instance_notified_klass_string_logged_imethods.new.i_with_dsplat
      end
      expect(output).to match("i.log")
      expect(output).to match(Regexp.escape("args=() payload={}"))
    end

    it "has correct return value" do
      expect(instance_notified_klass_string_logged_imethods.new.i).to eq(40)
    end
  end

  describe "::debug_time" do
    subject(:debug_time) { described_class.debug_time(time_or_monotonic) }

    context "when float" do
      let(:time_or_monotonic) { 0.1 }

      it "returns a time" do
        expect(debug_time.to_i).to eq(0)
      end
    end

    context "when time" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23) }

      it "returns a time" do
        expect(debug_time.to_i).to eq(1698696323)
      end
    end

    context "when datetime" do
      let(:time_or_monotonic) { DateTime.new(2019, 8, 10, 4, 10, 9) }

      it "returns a time" do
        expect(debug_time.year).to eq(2019)
      end
    end

    context "when string" do
      let(:time_or_monotonic) { Time.new(2023, 10, 31, 3, 5, 23).to_s }

      it "returns a time" do
        expect(debug_time.to_i).to eq(1698696323)
      end
    end

    context "when otherwise" do
      let(:time_or_monotonic) { :time }

      it "returns a time" do
        expect(debug_time).to be_within(5).of(Time.now)
      end
    end
  end
end
