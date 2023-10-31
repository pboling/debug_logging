# frozen_string_literal: true

RSpec.describe DebugLogging::InstanceLogger do
  include_context "with example classes"

  context "an instance logged klass with no logged methods" do
    it "logs" do
      output = capture("stdout") do
        complete_logged_klass_no_logged_imethods.new.i
        complete_logged_klass_no_logged_imethods.new.i_with_ssplat
        complete_logged_klass_no_logged_imethods.new.i_with_dsplat
      end
      expect(output).to eq("")
    end

    it "has correct return value" do
      expect(complete_logged_klass_no_logged_imethods.new.i).to eq(40)
    end
  end

  context "an instance logged klass explicit" do
    it "logs" do
      output = capture("stdout") do
        instance_logged_klass_explicit.new.i
        instance_logged_klass_explicit.new.i_with_ssplat
        instance_logged_klass_explicit.new.i_with_dsplat
      end
      expect(output).to match(/#i\(\)/)
      expect(output).to match(/#i_with_ssplat\(\)/)
      expect(output).to match(/#i_with_dsplat\(\)/)
    end

    it "has correct return value" do
      expect(instance_logged_klass_explicit.new.i).to eq(40)
    end
  end

  context "an instance logged klass dynamic" do
    context "instance method without args" do
      it "logs" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i
        end
        expect(output).to match(/#i\(\)/)
      end

      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i).to eq(40)
      end
    end

    context "instance method with single splat args" do
      it "logs" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/)
      end

      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat(
          "a",
          1,
          true,
          ["b", 2, false],
          {c: :d, e: :f},
        )).to eq(50)
      end
    end

    context "instance method with double splat args" do
      it "logs" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i_with_dsplat(
            a: "a",
            b: 1,
            c: true,
            d: ["b", 2, false],
            e: {c: :d, e: :f},
          )
        end
        expect(output).to match(/#i_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/)
      end

      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_dsplat(
          a: "a",
          b: 1,
          c: true,
          d: ["b", 2, false],
          e: {c: :d, e: :f},
        )).to eq(60)
      end
    end

    context "instance method not logged" do
      it "does not log" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i_without_log
        end
        expect(output).not_to receive(:debug_log)
      end

      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_without_log).to eq(0)
      end
    end
  end

  context "a singleton logged klass" do
    context "class method without args" do
      it "logs" do
        output = capture("stdout") do
          singleton_logged_klass.k
        end
        expect(output).to match(/\.k\(\)/)
      end

      it "has correct return value" do
        expect(singleton_logged_klass.k).to eq(10)
      end
    end

    context "class method with single splat args" do
      it "logs" do
        output = capture("stdout") do
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/)
      end

      it "has correct return value" do
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end

    context "class method with double splat args" do
      it "logs" do
        output = capture("stdout") do
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        expect(output).to match(/\.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/)
      end

      it "has correct return value" do
        expect(singleton_logged_klass.k_with_dsplat(
          a: "a",
          b: 1,
          c: true,
          d: ["b", 2, false],
          e: {c: :d, e: :f},
        )).to eq(30)
      end
    end

    context "class method not logged" do
      it "does not log" do
        output = capture("stdout") do
          singleton_logged_klass.k_without_log
        end
        expect(output).to eq("")
      end

      it "has correct return value" do
        expect(singleton_logged_klass.k_without_log).to eq(0)
      end
    end
  end

  describe "with config" do
    context "logger's log_level" do
      let(:logger) do
        l = Logger.new($stdout)
        l.level = Logger::INFO
        l
      end

      it "is maintained" do
        simple_klass.send(
          :include,
          described_class.new(
            i_methods: %i[initialize],
            config: {logger: logger, log_level: :debug},
          ),
        )
        expect(simple_klass.debug_log_level).to eq(:debug)
        simple_klass.new
        config_proxy = simple_klass.instance_variable_get(DebugLogging::Configuration.config_pointer(
          "ilm",
          :initialize,
        ))
        expect(config_proxy).to be_a(DebugLogging::Configuration)
        expect(logger.level).to eq(Logger::INFO)
        expect(simple_klass.debug_logger.level).to eq(Logger::DEBUG)
        expect(config_proxy.logger.level).to eq(Logger::INFO)
      end

      it "is used" do
        expect(logger).to receive(:debug).once
        expect(logger.level).to eq(Logger::INFO)
        # The debug log will be skipped, because the logger's level is info
        simple_klass.send(
          :include,
          described_class.new(
            i_methods: %i[initialize],
            config: {logger: logger, log_level: :debug},
          ),
        )
        expect(simple_klass.debug_log_level).to eq(:debug)
        simple_klass.new
        config_proxy = simple_klass.instance_variable_get(DebugLogging::Configuration.config_pointer(
          "ilm",
          :initialize,
        ))
        expect(config_proxy).to be_a(DebugLogging::Configuration)
        expect(simple_klass.debug_logger.level).to eq(Logger::DEBUG)
        expect(config_proxy.logger.level).to eq(Logger::INFO)
        expect(config_proxy.log_level).to eq(:debug)
      end
    end
  end
end
