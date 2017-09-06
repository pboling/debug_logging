require "spec_helper"

RSpec.describe DebugLogging::Configuration do
  include_context "with example classes"
  context "config" do
    context "global inherited config" do
      context "with block" do
        context "instance logging" do
          before do
            DebugLogging.configure do |config|
              config.instance_benchmarks = true
              config.add_invocation_id = true # invocation id allows you to identify a method call uniquely in a log
            end
            instance_logged_klass_explicit.debug_instance_benchmarks = false
            instance_logged_klass_explicit.debug_add_invocation_id = false
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            allow(instance_logged_klass_explicit).to receive(:debug_log) { logger }
          end
          it "keeps separate configs" do
            expect(DebugLogging.configuration.instance_benchmarks).to eq(true)
            expect(DebugLogging.configuration.add_invocation_id).to eq(true)
            expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(true)
            expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(true)
            expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(false)
            expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(false)
          end
          it "uses separate configs" do
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
            expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
            expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).never
            instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
            instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
            expect(instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          end
        end
        context "class logging" do
          before do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            DebugLogging.configure do |config|
              config.class_benchmarks = true
              config.add_invocation_id = true # invocation id allows you to identify a method call uniquely in a log
            end
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            allow(complete_logged_klass).to receive(:debug_log) { logger }
            complete_logged_klass.debug_class_benchmarks = false
            complete_logged_klass.debug_add_invocation_id = false
          end
          it "keeps separate configs" do
            expect(DebugLogging.configuration.class_benchmarks).to eq(true)
            expect(DebugLogging.configuration.add_invocation_id).to eq(true)
            expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
            expect(singleton_logged_klass.debug_add_invocation_id).to eq(true)
            expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
            expect(complete_logged_klass.debug_add_invocation_id).to eq(false)
          end
          it "uses separate configs" do
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
            expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
            expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).never
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
            complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
            expect(complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
      end
    end
    context "per class config" do
      context "instance logging" do
        before do
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
          allow(instance_logged_klass_explicit).to receive(:debug_log) { logger }
          instance_logged_klass_dynamic.debug_instance_benchmarks = true
          instance_logged_klass_dynamic.debug_add_invocation_id = true
          instance_logged_klass_explicit.debug_instance_benchmarks = false
          instance_logged_klass_explicit.debug_add_invocation_id = false
        end
        it "keeps separate configs" do
          expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(true)
          expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(true)
          expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(false)
          expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(false)
        end
        it "uses separate configs" do
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).never
          instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          expect(instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
        end
      end
      context "class logging" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          allow(complete_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_class_benchmarks = true
          singleton_logged_klass.debug_add_invocation_id = true
          complete_logged_klass.debug_class_benchmarks = false
          complete_logged_klass.debug_add_invocation_id = false
        end
        it "keeps separate configs" do
          expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
          expect(singleton_logged_klass.debug_add_invocation_id).to eq(true)
          expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
          expect(complete_logged_klass.debug_add_invocation_id).to eq(false)
        end
        it "uses separate configs" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
          expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
          expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in/, anything()).never
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          expect(complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
    end
    context "per method config" do
      let(:instance_logged_klass_explicit) {
        Class.new do
          # adds the helper methods to the class, all are prefixed with debug_*
          extend DebugLogging
          self.debug_instance_benchmarks = true
          self.debug_add_invocation_id = true
          # Includes a new anonymous module each time, so can include multiple times, each with a different config!
          include DebugLogging::InstanceLogger.new(i_methods: [:i], config: { instance_benchmarks: false })
          include DebugLogging::InstanceLogger.new(i_methods: [:i_with_ssplat], config: { add_invocation_id: false })
          include DebugLogging::InstanceLogger.new(i_methods: [:i_with_dsplat], config: { instance_benchmarks: false, add_invocation_id: false })
          def i; 40; end
          def i_with_ssplat(*args); 50; end
          def i_with_dsplat(**args); 60; end
          def i_without_customization; 0; end
          def i_without_log; 0; end
        end
      }

      let(:instance_logged_klass_dynamic) {
        Class.new do
          # adds the helper methods to the class, all are prefixed with debug_*
          extend DebugLogging
          self.debug_instance_benchmarks = false
          self.debug_add_invocation_id = false
          def i; 40; end
          def i_with_ssplat(*args); 50; end
          def i_with_dsplat(**args); 60; end
          # A bit redundant - but you can override the class settings above,
          #   which would apply to singleton and instance methods for this class,
          #   for all *instance* methods, like this:
          include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false), config: { add_invocation_id: true })
          def i_without_log; 0; end
        end
      }
      context "instance logging" do
        before do
          allow(instance_logged_klass_explicit).to receive(:debug_log) { logger }
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
        end
        it "keeps separate configs" do
          expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(true)
          expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(true)
          expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(false)
          expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(false)
        end
        it "uses separate configs" do
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i\(\) ~\d+@.+~/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i completed in/, anything()).never
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)\Z/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\)\Z/, anything()).once
          expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_dsplat completed in/, anything()).never
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~\Z/, anything()).once
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in/, anything()).never
          instance_logged_klass_explicit.new.i
          instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          instance_logged_klass_explicit.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
          instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(instance_logged_klass_explicit.new.i).to eq(40)
          expect(instance_logged_klass_explicit.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          expect(instance_logged_klass_explicit.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(60)
          expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
        end
      end
      context "class logging" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          allow(complete_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_class_benchmarks = true
          singleton_logged_klass.debug_add_invocation_id = true
          complete_logged_klass.debug_class_benchmarks = false
          complete_logged_klass.debug_add_invocation_id = false
        end
        it "keeps separate configs" do
          expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
          expect(singleton_logged_klass.debug_add_invocation_id).to eq(true)
          expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
          expect(complete_logged_klass.debug_add_invocation_id).to eq(false)
        end
        it "uses separate configs" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
          expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
          expect(complete_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in/, anything()).never
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          expect(complete_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
    end
    context "last_hash_to_s_proc" do
      context "class level config" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
        end
        it "logs" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
      context "instance level config" do
        before do
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
          instance_logged_klass_dynamic.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
        end
        it "logs" do
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(60)
        end
      end
    end
    context "multiple_last_hashes" do
      context "class level config" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          singleton_logged_klass.debug_multiple_last_hashes = true
        end
        it "logs" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], \[:c, :e\], \[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f}, a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f}, a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(20)
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
      context "instance level config" do
        before do
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
          instance_logged_klass_dynamic.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          instance_logged_klass_dynamic.debug_multiple_last_hashes = true
        end
        it "logs" do
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], \[:c, :e\], \[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/, anything()).once
          instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f}, a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
          instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f}, a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(50)
          expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(60)
        end
      end
    end
    context "last_hash_max_length" do
      context "when last_hash_to_s_proc is set" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          singleton_logged_klass.debug_last_hash_max_length = 3
        end
        it "logs ellipsis" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_dsplat\(\[:a, ✂️ …\) ~/, anything()).once
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
      context "when last_hash_to_s_proc is not set" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = nil
          singleton_logged_klass.debug_last_hash_max_length = 3
        end
        it "logs full message" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/, anything()).once
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
    end
    context "args_max_length" do
      context "when last_hash_to_s_proc is set" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          singleton_logged_klass.debug_args_max_length = 20
        end
        it "logs full messages when under max" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \[:c, :e\]\) ~/, anything()).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, {c: :d, e: :f})
        end
        it "logs ellipsis" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \[\"b\", 2 ✂️ …, \[:c, :e\]\) ~/, anything()).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
      context "when last_hash_to_s_proc is not set" do
        before do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = nil
          singleton_logged_klass.debug_args_max_length = 20
        end
        it "logs full messages when under max" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, {:c=>:d}\) ~/, anything()).once
          singleton_logged_klass.k_with_ssplat("a", 1, {c: :d})
        end
        it "logs ellipsis" do
          expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2 ✂️ …\) ~/, anything()).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
    end
    context "instance_benchamrks" do
      before do
        allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
        instance_logged_klass_dynamic.debug_instance_benchmarks = true
      end
      it "logs benchmark" do
        expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/, anything()).once
        expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~/, anything()).once
        instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
      end
    end
    context "class_benchamrks" do
      before do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        allow(singleton_logged_klass).to receive(:debug_log) { logger }
        singleton_logged_klass.debug_class_benchmarks = true
      end
      it "logs benchmark" do
        expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/, anything()).once
        expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~/, anything()).once
        singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end
    context "add_invocation_id" do
      context "singleton" do
        context "add_invocation_id is true" do
          before do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = true
          end
          it "logs benchmark" do
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
        context "add_invocation_id is false" do
          before do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = false
          end
          it "logs benchmark" do
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)\Z/, anything()).once
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
        context "add_invocation_id is proc" do
          before do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = ->(colorized_string) { colorized_string.red }
          end
          it "logs benchmark" do
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\).*0;31;49m ~\d+@.+~.*0m\Z/, anything()).once
            expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\).*0;31;49m ~\d+@.+~.*0m\Z/, anything()).once
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
      end
      context "instance" do
        context "add_invocation_id is true" do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = true
          end
          it "logs benchmark" do
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/, anything()).once
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/, anything()).once
            instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          end
        end
        context "add_invocation_id is false" do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = false
          end
          it "logs benchmark" do
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/, anything()).once
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)\Z/, anything()).once
            instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          end
        end
        context "add_invocation_id is proc" do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = ->(colorized_string) { colorized_string.red }
          end
          it "logs benchmark" do
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\).*0;31;49m ~\d+@.+~.*0m\Z/, anything()).once
            expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\).*0;31;49m ~\d+@.+~.*0m\Z/, anything()).once
            instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          end
        end
      end
    end
  end
end
