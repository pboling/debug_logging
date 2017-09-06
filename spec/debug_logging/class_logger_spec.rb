require "spec_helper"

RSpec.describe DebugLogging::ClassLogger do
  include_context "with example classes"

  context "logged macro" do
    it "works with an implicit array of methods and a configuration override hash" do
      expect(complete_logged_klass).to receive(:debug_log).with(/.k_with_dsplat_i\(LOLiii\)/, anything()).once
      complete_logged_klass.k_with_dsplat_i(a: 'a')
    end
    it "works with an explicit array of methods and a configuration override hash" do
      expect(complete_logged_klass).to receive(:debug_log).with(/.k_with_dsplat_e\(LOLeee\)/, anything()).once
      complete_logged_klass.k_with_dsplat_e(a: 'a')
    end
  end

  context "a complete logged class" do
    before do
      skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
      allow(complete_logged_klass).to receive(:debug_log) { logger }
    end
    it "logs" do
      expect(complete_logged_klass).to receive(:debug_log).with(/#i\(\)/, anything()).once
      expect(complete_logged_klass).to receive(:debug_log).with(/#i_with_ssplat\(\)/, anything()).once
      expect(complete_logged_klass).to receive(:debug_log).with(/#.*0;31;49mi_with_dsplat.*0m\(\)/, anything()).once
      expect(complete_logged_klass).to receive(:debug_log).with(/.k\(\)/, anything()).once
      expect(complete_logged_klass).to receive(:debug_log).with(/.k_with_ssplat\(\)/, anything()).once
      expect(complete_logged_klass).to receive(:debug_log).with(/.k_with_dsplat\(\)/, anything()).once
      complete_logged_klass.new.i
      complete_logged_klass.new.i_with_ssplat
      complete_logged_klass.new.i_with_dsplat
      complete_logged_klass.k
      complete_logged_klass.k_with_ssplat
      complete_logged_klass.k_with_dsplat
    end
    it "has correct return value" do
      expect(complete_logged_klass.new.i).to eq(40)
      expect(complete_logged_klass.k).to eq(10)
    end
  end
end
