require "spec_helper"

RSpec.describe DebugLogging::ClassLogger do
  include_context "with example classes"

  context "logged macro" do
    it "works witout configuration override hash" do
      expect(complete_logged_klass.debug_config).to receive(:log).once.and_call_original
      output = capture('stdout') do
        complete_logged_klass.k_with_dsplat(a: 'a')
      end
      expect(output).to match(/.*\.k_with_dsplat/)
      # Can't set an expectation on the per class method config until after the method has been called once, as that is when the ivar gets set.
      # Without an options hash the class config is the same config object as the per method config
      expect(complete_logged_klass.instance_variable_get(DebugLogging::Configuration.config_pointer('k', :k_with_dsplat))).to receive(:log)
      complete_logged_klass.k_with_dsplat(a: 'a')
    end

    it "works with an implicit array of methods and a configuration override hash" do
      # because the options to logged in the class definition cause the creation of a method specific config instance
      expect(complete_logged_klass.debug_config).to_not receive(:log)
      output = capture('stdout') do
        complete_logged_klass.k_with_dsplat_i(a: 'a')
      end
      expect(output).to match(/\.k_with_dsplat_i\(LOLiii\)/)
      # Can't set an expectation on the per class method config until after the method has been called once, as that is when the ivar gets set.
      expect(complete_logged_klass.instance_variable_get(DebugLogging::Configuration.config_pointer('k', :k_with_dsplat_i))).to receive(:log).once.and_call_original
      complete_logged_klass.k_with_dsplat_i(a: 'a')
    end
    it "works with an explicit array of methods and a configuration override hash" do
      # because the options to logged in the class definition cause the creation of a method specific config instance
      expect(complete_logged_klass.debug_config).to_not receive(:log)
      output = capture('stdout') do
        complete_logged_klass.k_with_dsplat_e(a: 'a')
      end
      expect(output).to match(/.*0;31;49m#<Class.*0m\.k_with_dsplat_e\(LOLeee\)/)
      # Can't set an expectation on the per class method config until after the method has been called once, as that is when the ivar gets set.
      expect(complete_logged_klass.instance_variable_get(DebugLogging::Configuration.config_pointer('k', :k_with_dsplat_e))).to receive(:log).once.and_call_original
      complete_logged_klass.k_with_dsplat_e(a: 'a')
    end
  end

  context "a complete logged class" do
    before do
      skip_for(engine: "ruby", versions: ["2.0.0"], reason: "method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible")
      allow(complete_logged_klass.debug_config).to receive(:debug_log) { logger }
    end
    it "logs" do
      output = capture('stdout') do
        complete_logged_klass.new.i
        complete_logged_klass.new.i_with_ssplat
        complete_logged_klass.new.i_with_dsplat
        complete_logged_klass.k
        complete_logged_klass.k_with_ssplat
        complete_logged_klass.k_with_dsplat
      end
      expect(output).to match(/#i\(\)/)
      expect(output).to match(/#i_with_ssplat\(\)/)
      expect(output).to match(/#.*0;31;49mi_with_dsplat.*0m\(\)/)
      expect(output).to match(/\.k\(\)/)
      expect(output).to match(/\.k_with_ssplat\(\)/)
      expect(output).to match(/\.k_with_dsplat\(\)/)
    end
    it "has correct return value" do
      expect(complete_logged_klass.new.i).to eq(40)
      expect(complete_logged_klass.k).to eq(10)
    end
  end
end
