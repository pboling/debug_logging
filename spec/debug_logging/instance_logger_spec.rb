require "spec_helper"

RSpec.describe DebugLogging::InstanceLogger do
  include_context "with example classes"

  context "an instance logged klass explicit" do
    before { allow(instance_logged_klass_explicit).to receive(:debug_log) { logger } }
    it "logs" do
      expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i\(\)/, anything()).once
      expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_ssplat\(\)/, anything()).once
      expect(instance_logged_klass_explicit).to receive(:debug_log).with(/#i_with_dsplat\(\)/, anything()).once
      instance_logged_klass_explicit.new.i
      instance_logged_klass_explicit.new.i_with_ssplat
      instance_logged_klass_explicit.new.i_with_dsplat
    end
    it "has correct return value" do
      expect(instance_logged_klass_explicit.new.i).to eq(40)
    end
  end

  context "an instance logged klass dynamic" do
    before { allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger } }
    context "instance method without args" do
      it "logs" do
        expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i\(\)/, anything()).once
        instance_logged_klass_dynamic.new.i
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i).to eq(40)
      end
    end
    context "instance method with single splat args" do
      it "logs" do
        expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/, anything()).once
        instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(50)
      end
    end
    context "instance method with double splat args" do
      it "logs" do
        expect(instance_logged_klass_dynamic).to receive(:debug_log).with(/#i_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/, anything()).once
        instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(60)
      end
    end
    context "instance method not logged" do
      it "does not log" do
        expect(instance_logged_klass_dynamic).to_not receive(:debug_log)
        instance_logged_klass_dynamic.new.i_without_log
      end
      it "has correct return value" do
        expect(instance_logged_klass_dynamic.new.i_without_log).to eq(0)
      end
    end
  end

  context "a singleton logged klass" do
    before do
      skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
      allow(singleton_logged_klass).to receive(:debug_log) { logger }
    end
    context "class method without args" do
      it "logs" do
        expect(singleton_logged_klass).to receive(:debug_log).with(/\.k\(\)/, anything()).once
        singleton_logged_klass.k
      end
      it "has correct return value" do
        expect(singleton_logged_klass.k).to eq(10)
      end
    end
    context "class method with single splat args" do
      it "logs" do
        expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/, anything()).once
        singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(singleton_logged_klass.k_with_ssplat("a", 1, true, ["b", 2, false], {c: :d, e: :f})).to eq(20)
      end
    end
    context "class method with double splat args" do
      it "logs" do
        expect(singleton_logged_klass).to receive(:debug_log).with(/\.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/, anything()).once
        singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})
      end
      it "has correct return value" do
        expect(singleton_logged_klass.k_with_dsplat(a: "a", b: 1, c: true, d: ["b", 2, false], e: {c: :d, e: :f})).to eq(30)
      end
    end
    context "class method not logged" do
      it "does not log" do
        expect(singleton_logged_klass).to_not receive(:debug_log)
        singleton_logged_klass.k_without_log
      end
      it "has correct return value" do
        expect(singleton_logged_klass.k_without_log).to eq(0)
      end
    end
  end
end
