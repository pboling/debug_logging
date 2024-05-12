DebugLogging.configuration.active_support_notifications = true

RSpec.describe DebugLogging::ClassNotifier do
  include_context "with example classes"
  let(:events) { [] }

  before do
    ActiveSupport::Notifications.subscribe(/log/) do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  it "logs through the config proxy" do
    # Have to call it twice to test, because before the first call the config proxy isn't prepared yet
    complete_notified_klass.k_with_dsplat_payload_and_config(a: "a")
    config_proxy = complete_notified_klass.instance_variable_get(DebugLogging::Configuration.config_pointer(
      "kn",
      :k_with_dsplat_payload_and_config,
    ))
    expect(config_proxy).to receive(:log).once.and_call_original
    complete_notified_klass.k_with_dsplat_payload_and_config(a: "a")
  end

  context "when notified macro" do
    it "works without payload override hash" do
      expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
      output = capture("stdout") do
        complete_notified_klass.k_with_dsplat(a: "a")
      end
      expect(output).to match("k_with_dsplat.log")
      expect(output).to match('args=\(\*\*{:a=>"a"}\) payload={}')
      expect(events.length).to eq(1)
      event = events.first
      expect(event).to have_attributes(
        name: "k_with_dsplat.log",
        payload: {
          config_proxy: instance_of(DebugLogging::Configuration),
          debug_args: [{a: "a"}],
        },
      )
    end

    it "works with a payload override hash" do
      expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
      output = capture("stdout") do
        complete_notified_klass.k_with_dsplat_payload(a: "a")
      end
      expect(events.first).to have_attributes(
        name: "k_with_dsplat_payload.log",
        payload: {
          config_proxy: instance_of(DebugLogging::Configuration),
          debug_args: [{a: "a"}],
          id: 2,
          first_name: "Bae",
          last_name: "Fae",
        },
      )
      expect(output).to match("k_with_dsplat_payload.log")
      expect(output).to match('args=\(\*\*{:a=>"a"}\) payload={:id=>2, :first_name=>"Bae", :last_name=>"Fae"}')
    end

    it "works with a config override hash" do
      expect(complete_notified_klass.debug_config).not_to receive(:log)
      output = capture("stdout") do
        complete_notified_klass.k_with_dsplat_payload_and_config(a: "a")
      end
      expect(events.first).to have_attributes(
        name: "k_with_dsplat_payload_and_config.log",
        payload: {
          config_proxy: instance_of(DebugLogging::Configuration),
          debug_args: [{a: "a"}],
          id: 3,
          first_name: "Jae",
          last_name: "Tae",
        },
      )
      expect(output).to match("ERROR")
      expect(output).to match(Regexp.escape("k_with_dsplat_payload_and_config.log"))
      expect(output).to match(Regexp.escape('args=(**{:a=>"a"})'))
      expect(output).to match(Regexp.escape('payload={:id=>3, :first_name=>"Jae", :last_name=>"Tae"}'))
    end
  end

  context "a complete notified class" do
    before do
      allow(complete_notified_klass.debug_config).to receive(:debug_log) { logger }
    end

    it "notified all methods" do
      output = capture("stdout") do
        complete_notified_klass.new.i
        complete_notified_klass.new.i_with_ssplat
        complete_notified_klass.new.i_with_dsplat
        complete_notified_klass.new.i_with_dsplat_payload
        complete_notified_klass.new.i_with_dsplat_payload_and_config
        complete_notified_klass.new.i_with_dsplat_handled_error
        complete_notified_klass.k
        complete_notified_klass.k_with_ssplat
        complete_notified_klass.k_with_dsplat
        complete_notified_klass.k_with_dsplat_payload
        complete_notified_klass.k_with_dsplat_payload_and_config
        complete_notified_klass.k_with_dsplat_handled_error
      end
      expect(output).to match("i.log")
      expect(output).to match(Regexp.escape("args=() payload={}"))
      expect(output).to match("i_with_ssplat.log")
      expect(output).to match('payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}')
      expect(output).to match("i_with_dsplat.log")
      expect(output).to match('payload={:salutation=>"Mr.", :suffix=>"Jr."}')
      expect(output).to match("i_with_dsplat_payload.log")
      expect(output).to match('["blue", "green"]')
      expect(output).to match("i_with_dsplat_payload_and_config.log")
      expect(output).to match('["yellow", "red"]')
      # Config options do not bleed through
      expect(output).not_to match("add_invocation_id")
      expect(output).to match("k.log")
      expect(output).to match("k_with_ssplat.log")
      expect(output).to match("k_with_dsplat.log")
      expect(output).to match("k_with_dsplat_payload.log")
      expect(output).to match('payload={:id=>2, :first_name=>"Bae", :last_name=>"Fae"}')
      expect(output).to match("k_with_dsplat_payload_and_config.log")
      expect(output).to match('payload={:id=>3, :first_name=>"Jae", :last_name=>"Tae"}')
      # Config options do not bleed through
      expect(output).not_to match("log_level")
      expect(events[0]).to have_attributes(
        name: "i.log",
        payload: {
          debug_args: [],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[1]).to have_attributes(
        name: "i_with_ssplat.log",
        payload: {
          debug_args: [],
          id: 1,
          first_name: "Joe",
          last_name: "Schmoe",
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[2]).to have_attributes(
        name: "i_with_dsplat.log",
        payload: {
          debug_args: [],
          salutation: "Mr.",
          suffix: "Jr.",
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[3]).to have_attributes(
        name: "i_with_dsplat_payload.log",
        payload: {
          debug_args: [],
          tags: %w[blue green],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[4]).to have_attributes(
        name: "i_with_dsplat_payload_and_config.log",
        payload: {
          debug_args: [],
          tags: %w[yellow red],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[5]).to have_attributes(
        name: "i_with_dsplat_handled_error.log",
        payload: {
          debug_args: [],
          tags: %w[yellow red],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[6]).to have_attributes(
        name: "k.log",
        payload: {
          debug_args: [],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[7]).to have_attributes(
        name: "k_with_ssplat.log",
        payload: {
          debug_args: [],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[8]).to have_attributes(
        name: "k_with_dsplat.log",
        payload: {
          debug_args: [],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[9]).to have_attributes(
        name: "k_with_dsplat_payload.log",
        payload: {
          debug_args: [],
          id: 2,
          first_name: "Bae",
          last_name: "Fae",
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[10]).to have_attributes(
        name: "k_with_dsplat_payload_and_config.log",
        payload: {
          debug_args: [],
          id: 3,
          first_name: "Jae",
          last_name: "Tae",
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events[11]).to have_attributes(
        name: "k_with_dsplat_handled_error.log",
        payload: {
          debug_args: [],
          config_proxy: instance_of(DebugLogging::Configuration),
        },
      )
      expect(events.length).to eq(12)
    end

    it "notified class methods" do
      output = capture("stdout") do
        complete_notified_klass.k
        complete_notified_klass.k_with_ssplat
        complete_notified_klass.k_with_dsplat
      end
      expect(output).to match("k.log")
      expect(output).to match(Regexp.escape("args=() payload={}"))
      expect(output).to match("k_with_ssplat.log")
      expect(output).to match("k_with_dsplat.log")
      expect(events).to contain_exactly(
        have_attributes(
          name: "k.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
        have_attributes(
          name: "k_with_ssplat.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
        have_attributes(
          name: "k_with_dsplat.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
      )
    end

    it "notified instance methods" do
      output = capture("stdout") do
        complete_notified_klass.new.i
        complete_notified_klass.new.i_with_ssplat
        complete_notified_klass.new.i_with_dsplat
      end
      expect(output).to match("i.log")
      expect(output).to match(Regexp.escape("args=() payload={}"))
      expect(output).to match("i_with_ssplat.log")
      expect(output).to match('payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}')
      expect(output).to match("i_with_dsplat.log")
      expect(output).to match('payload={:salutation=>"Mr.", :suffix=>"Jr."}')
      expect(events).to contain_exactly(
        have_attributes(
          name: "i.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
        have_attributes(
          name: "i_with_ssplat.log",
          payload: {
            debug_args: [],
            id: 1,
            first_name: "Joe",
            last_name: "Schmoe",
            config_proxy: instance_of(DebugLogging::Configuration),
          },
        ),
        have_attributes(
          name: "i_with_dsplat.log",
          payload: {
            debug_args: [],
            salutation: "Mr.",
            suffix: "Jr.",
            config_proxy: instance_of(DebugLogging::Configuration),
          },
        ),
      )
    end

    it "notified multiple method calls" do
      output = capture("stdout") do
        complete_notified_klass.new.i_with_ssplat
        complete_notified_klass.new.i_with_ssplat
        complete_notified_klass.k_with_ssplat
        complete_notified_klass.k_with_ssplat
      end
      expect(output).to match("i_with_ssplat.log")
      expect(output).to match('payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}')
      expect(output).to match("i_with_ssplat.log")
      expect(output).to match('payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}')
      expect(output).to match("k_with_ssplat.log")
      expect(output).to match(Regexp.escape("args=() payload={}"))
      expect(output).to match("k_with_ssplat.log")
      expect(events).to contain_exactly(
        have_attributes(
          name: "i_with_ssplat.log",
          payload: {
            debug_args: [],
            id: 1,
            first_name: "Joe",
            last_name: "Schmoe",
            config_proxy: instance_of(DebugLogging::Configuration),
          },
        ),
        have_attributes(
          name: "i_with_ssplat.log",
          payload: {
            debug_args: [],
            id: 1,
            first_name: "Joe",
            last_name: "Schmoe",
            config_proxy: instance_of(DebugLogging::Configuration),
          },
        ),
        have_attributes(
          name: "k_with_ssplat.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
        have_attributes(
          name: "k_with_ssplat.log",
          payload: {debug_args: [], config_proxy: instance_of(DebugLogging::Configuration)},
        ),
      )
    end

    it "has correct return value" do
      expect(complete_notified_klass.new.i).to eq(40)
      expect(complete_notified_klass.k).to eq(10)
    end
  end
end
