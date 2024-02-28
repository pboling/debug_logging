# # frozen_string_literal: true

# class ParentSingletonClass
#   # adds the helper methods to the class, all are prefixed with debug_*,
#   #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
#   extend DebugLogging
#   # Needs to be at the top of the class, adds `i_logged` class method
#   extend DebugLogging::InstanceLogger
#   # Needs to be at the top of the class, adds `notified` class method
#   # extend DebugLogging::ClassNotifier
#   self.debug_instance_benchmarks = false
#   self.debug_add_invocation_id = false
#   self.debug_ellipsis = "..."
#   self.debug_last_hash_max_length = 888
#
#   i_logged def perform(*_args)
#     42
#   end
#
#   def banana(**_args)
#     77
#   end
#   i_logged :banana
# end
#
# RSpec.describe DebugLogging::InstanceLogger do
#   context "when an instance logged klass with no logged methods" do
#     it "logs" do
#       output = capture("stdout") do
#         ParentSingletonClass.new.perform(1, 2, "a", [true, false], hella: "good", baby: "metal")
#         ParentSingletonClass.new.banana(one: 1, two: 2, a: "a", bool: [true, false], hella: "good", baby: "metal")
#       end
#       expect(output).to eq("")
#     end
#
#     # it "has correct return value" do
#     #   expect(ParentSingletonClass.new.perform).to eq(42)
#     #   expect(ParentSingletonClass.new.banana).to eq(77)
#     # end
#   end
# end

RSpec.describe DebugLogging::InstanceLogger do
  include_context "with example classes"

  let(:color_regex) { /\033\[[0-9;]+m/.source }

  context "when an instance logged klass with no logged methods" do
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

  context "when an instance logged klass explicit" do
    it "logs" do
      output = capture("stdout") do
        instance_logged_klass_explicit.new.i
        instance_logged_klass_explicit.new.i_with_ssplat
        instance_logged_klass_explicit.new.i_with_dsplat
      end
      expect(output).to match(/#i\(\*\*{}\)/)
      expect(output).to match(/#i_with_ssplat\(\*\*{}\)/)
      expect(output).to match(/#i_with_dsplat\(\*\*{}\)/)
    end

    it "has correct return value" do
      expect(instance_logged_klass_explicit.new.i).to eq(40)
    end
  end

  context "when an instance logged klass dynamic" do
    context "when instance method without args" do
      it "logs" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i
        end
        expect(output).to match(/#i\(\*\*{}\)/)
      end

      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i).to eq(40)
      end
    end

    context "when instance method with single splat args" do
      it "logs" do
        output = capture("stdout") do
          instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}, {}\) ~/)
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

    context "when instance method with double splat args" do
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

    context "when instance method not logged" do
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

  context "when a singleton logged klass" do
    context "when class method without args" do
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

    context "when class method with single splat args" do
      it "logs" do
        output = capture("stdout") do
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        expect(output).to match(/\.#{color_regex}k_with_ssplat#{color_regex}\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/)
      end

      it "has correct return value" do
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end

    context "when class method with double splat args" do
      it "logs" do
        output = capture("stdout") do
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        expect(output).to match(/\.#{color_regex}k_with_dsplat#{color_regex}\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/)
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

    context "when class method not logged" do
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
    context "when logger's log_level" do
      let(:logger) do
        l = Logger.new($stdout)
        l.level = Logger::INFO
        l
      end

      it "is maintained" do
        simple_klass.send(:extend, described_class)
        simple_klass.send(:i_logged, %i[initialize], {logger: logger, log_level: :debug})
        simple_klass.class_eval do
          define_method :rattle do
            88
          end
        end

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
        simple_klass.send(:extend, described_class)
        simple_klass.send(:i_logged, %i[initialize], {logger: logger, log_level: :debug})
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

  describe "complex per-method config" do
    it "maintains distinct configs" do
      output = capture("stdout") do
        complex_config = complex_config_logged_klass.new
        complex_config.rattle
      end
      expect(output).to match(/\##{color_regex}initialize#{color_regex}\(\*\*{}\) ~/)
      expect(output).to match(/\##{color_regex}rattle#{color_regex}\(\*\*{}\) ~/)
    end
  end
end
