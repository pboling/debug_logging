require "spec_helper"

RSpec.describe "DebugLogging" do
  before do
    logger = double("logger")
    allow(DebugLogging).to receive(:log) { logger }
  end
  after do
    DebugLogging.config_reset
  end

  it "has a version number" do
    expect(DebugLogging::VERSION).not_to be nil
  end

  let(:complete_logged_klass) {
    Class.new do
      # Needs to be at the top of the class
      extend DebugLogging::ClassLogger
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: [:i, :i_with_ssplat, :i_with_dsplat])
      logged def self.k; 10; end
      def self.k_with_ssplat(*args); 20; end
      def self.k_with_dsplat(**args); 30; end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_without_log; 0; end
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }

  let(:singleton_logged_klass) {
    Class.new do
      # Needs to be at the top of the class
      extend DebugLogging::ClassLogger
      logged def self.k; 10; end
      def self.k_with_ssplat(*args); 20; end
      def self.k_with_dsplat(**args); 30; end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_without_log; 0; end
    end
  }

  let(:instance_logged_klass_explicit) {
    Class.new do
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: [:i, :i_with_ssplat, :i_with_dsplat])
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }

  let(:instance_logged_klass_dynamic) {
    Class.new do
      def i; 40; end
      def i_with_ssplat(*args); 50; end
      def i_with_dsplat(**args); 60; end
      # Needs to be below any methods that will want logging when dynamic
      include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log; 0; end
    end
  }

  context "a complete logged class" do
    it "logs" do
      skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
      expect(DebugLogging).to receive(:log).with(/#i\(\)/).once
      expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\(\)/).once
      expect(DebugLogging).to receive(:log).with(/#i_with_dsplat\(\)/).once
      expect(DebugLogging).to receive(:log).with(/.k\(\)/).once
      expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\(\)/).once
      expect(DebugLogging).to receive(:log).with(/.k_with_dsplat\(\)/).once
      complete_logged_klass.new.i
      complete_logged_klass.new.i_with_ssplat
      complete_logged_klass.new.i_with_dsplat
      complete_logged_klass.k
      complete_logged_klass.k_with_ssplat
      complete_logged_klass.k_with_dsplat
    end
    it "has correct return value" do
      skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
      expect(complete_logged_klass.new.i).to eq(40)
      expect(complete_logged_klass.k).to eq(10)
    end
  end
  context "an instance logged klass explicit" do
    it "logs" do
      expect(DebugLogging).to receive(:log).with(/#i\(\)/).once
      expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\(\)/).once
      expect(DebugLogging).to receive(:log).with(/#i_with_dsplat\(\)/).once
      instance_logged_klass_explicit.new.i
      instance_logged_klass_explicit.new.i_with_ssplat
      instance_logged_klass_explicit.new.i_with_dsplat
    end
    it "has correct return value" do
      expect(instance_logged_klass_explicit.new.i).to eq(40)
    end
  end
  context "an instance logged klass dynamic" do
    context "instance method without args" do
      it "logs" do
        expect(DebugLogging).to receive(:log).with(/#i\(\)/).once
        instance_logged_klass_dynamic.new.i
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i).to eq(40)
      end
    end
    context "instance method with single splat args" do
      it "logs" do
        expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/).once
        instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
      end
    end
    context "instance method with double splat args" do
      it "logs" do
        expect(DebugLogging).to receive(:log).with(/#i_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/).once
        instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(60)
      end
    end
    context "instance method not logged" do
      it "does not log" do
        expect(DebugLogging).to_not receive(:log)
        instance_logged_klass_dynamic.new.i_without_log
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_without_log).to eq(0)
      end
    end
  end

  context "a singleton logged klass" do
    context "class method without args" do
      it "logs" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to receive(:log).with(/\.k\(\)/).once
        singleton_logged_klass.k
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k).to eq(10)
      end
    end
    context "class method with single splat args" do
      it "logs" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/).once
        singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end
    context "class method with double splat args" do
      it "logs" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to receive(:log).with(/.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/).once
        singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
      end
    end
    context "class method not logged" do
      it "does not log" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to_not receive(:log)
        singleton_logged_klass.k_without_log
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k_without_log).to eq(0)
      end
    end
  end

  context "config" do
    context "last_hash_to_s_proc" do
      before do
        DebugLogging.last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
      end
      it "logs" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to receive(:log).with(/.k_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/).once
        singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
      end
    end
    context "last_hash_max_length" do
      context "when last_hash_to_s_proc is set" do
        before do
          DebugLogging.last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          DebugLogging.last_hash_max_length = 3
        end
        it "logs ellipsis" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_dsplat\(\[:a, ✂️ …\) ~/).once
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
      context "when last_hash_to_s_proc is not set" do
        before do
          DebugLogging.last_hash_to_s_proc = nil
          DebugLogging.last_hash_max_length = 3
        end
        it "logs full message" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/).once
          singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
        end
        it "has correct return value" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
        end
      end
    end
    context "args_max_length" do
      context "when last_hash_to_s_proc is set" do
        before do
          DebugLogging.last_hash_to_s_proc = ->(hash) { "#{hash.keys}" }
          DebugLogging.args_max_length = 20
        end
        it "logs full messages when under max" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \[:c, :e\]\) ~/).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, {c: :d, e: :f})
        end
        it "logs ellipsis" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \[\"b\", 2 ✂️ …, \[:c, :e\]\) ~/).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
      context "when last_hash_to_s_proc is not set" do
        before do
          DebugLogging.last_hash_to_s_proc = nil
          DebugLogging.args_max_length = 20
        end
        it "logs full messages when under max" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, {:c=>:d}\) ~/).once
          singleton_logged_klass.k_with_ssplat("a", 1, {c: :d})
        end
        it "logs ellipsis" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \["b", 2 ✂️ …\) ~/).once
          singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
        end
        it "has correct return value" do
          skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
          expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
        end
      end
    end
    context "instance_benchamrks" do
      before do
        DebugLogging.instance_benchmarks = true
      end
      it "logs benchmark" do
        expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/).once
        expect(DebugLogging).to receive(:log).with(/#i_with_ssplat completed in \d+\.?\d*s ~/).once
        instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
      end
    end
    context "class_benchamrks" do
      before do
        DebugLogging.class_benchmarks = true
      end
      it "logs benchmark" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/).once
        expect(DebugLogging).to receive(:log).with(/.k_with_ssplat completed in \d+\.?\d*s ~/).once
        singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end
    context "add_invocation_id" do
      context "singleton" do
        context "add_invocation_id is true" do
          before do
            DebugLogging.class_benchmarks = true
            DebugLogging.add_invocation_id = true
          end
          it "logs benchmark" do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@\d+~/).once
            expect(DebugLogging).to receive(:log).with(/.k_with_ssplat completed in \d+\.?\d*s ~\d+@\d+~/).once
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
        context "add_invocation_id is false" do
          before do
            DebugLogging.class_benchmarks = true
            DebugLogging.add_invocation_id = false
          end
          it "logs benchmark" do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            expect(DebugLogging).to receive(:log).with(/.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/).once
            expect(DebugLogging).to receive(:log).with(/.k_with_ssplat completed in \d+\.?\d*s\Z/).once
            singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
            expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
          end
        end
      end
      context "instance" do
        context "add_invocation_id is true" do
          before do
            DebugLogging.instance_benchmarks = true
            DebugLogging.add_invocation_id = true
          end
          it "logs benchmark" do
            expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@\d+~/).once
            expect(DebugLogging).to receive(:log).with(/#i_with_ssplat completed in \d+\.?\d*s ~\d+@\d+~/).once
            instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
          end
          it "has correct return value" do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
          end
        end
        context "add_invocation_id is false" do
          before do
            DebugLogging.instance_benchmarks = true
            DebugLogging.add_invocation_id = false
          end
          it "logs benchmark" do
            expect(DebugLogging).to receive(:log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)\Z/).once
            expect(DebugLogging).to receive(:log).with(/#i_with_ssplat completed in \d+\.?\d*s\Z/).once
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
