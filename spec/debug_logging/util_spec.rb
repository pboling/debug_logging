RSpec.describe DebugLogging::Util do
  include_context "with example classes"

  before do
    @events = []
    @subscriber = ActiveSupport::Notifications.subscribe(/log/) do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  context "an instance notified klass with string logged methods" do
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
end
