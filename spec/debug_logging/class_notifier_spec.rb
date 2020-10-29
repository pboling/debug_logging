# frozen_string_literal: true

require 'spec_helper'
DebugLogging.configuration.active_support_notifications = true

RSpec.describe DebugLogging::ClassNotifier do
  include_context 'with example classes'

  before do
    @events = []
    @subscriber = ActiveSupport::Notifications.subscribe(/log/) do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  context 'notifies macro' do
    it 'works without payload override hash' do
      expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
      output = capture('stdout') do
        complete_notified_klass.k_with_dsplat(a: 'a')
      end
      expect(output).to match(/k_with_dsplat.log/)
      expect(output).to match(/payload={:debug_args=>\[{:a=>"a"}\]}/)
      expect(complete_notified_klass.instance_variable_get(DebugLogging::Configuration.config_pointer('k', :k_with_dsplat))).to receive(:log)
      expect(@events).to contain_exactly(
        have_attributes(name: /k_with_dsplat.log/, payload: { debug_args: [{ a: 'a' }] })
      )
      complete_notified_klass.k_with_dsplat(a: 'a')
    end

    it 'works with a payload override hash' do
      expect(complete_notified_klass.debug_config).to_not receive(:log)
      output = capture('stdout') do
        complete_notified_klass.k_with_dsplat_payload(a: 'a')
      end
      expect(output).to match(/k_with_dsplat_payload.log/)
      expect(output).to match(/payload={:debug_args=>\[{:a=>"a"}\], :id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}\n/)
      expect(complete_notified_klass.instance_variable_get(DebugLogging::Configuration.config_pointer('k', :k_with_dsplat_payload))).to receive(:log).once.and_call_original
      expect(@events).to contain_exactly(
        have_attributes(name: /k_with_dsplat_payload.log/, payload: { debug_args: [{ a: 'a' }], id: 1, first_name: 'Joe', last_name: 'Schmoe' })
      )
      complete_notified_klass.k_with_dsplat_payload(a: 'a')
    end
  end

  context 'a complete notified class' do
    before do
      skip_for(engine: 'ruby', versions: ['2.0.0'], reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
      allow(complete_notified_klass.debug_config).to receive(:debug_log) { logger }
    end

    it 'notifies' do
      output = capture('stdout') do
        complete_notified_klass.new.i
        complete_notified_klass.new.i_with_ssplat
        complete_notified_klass.new.i_with_dsplat
        complete_notified_klass.k
        complete_notified_klass.k_with_ssplat
        complete_notified_klass.k_with_dsplat
      end
      expect(output).to match(/i.log/)
      expect(output).to match(/payload={:debug_args=>\[\]}/)
      expect(output).to match(/i_with_ssplat.log/)
      expect(output).to match(/payload={:debug_args=>\[\], :id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}/)
      expect(output).to match(/i_with_dsplat.log/)
      expect(output).to match(/payload={:debug_args=>\[\], :salutation=>"Mr.", :suffix=>"Jr."}/)
      expect(output).to match(/k.log/)
      expect(output).to match(/payload={:debug_args=>\[\]}/)
      expect(output).to match(/k_with_ssplat.log/)
      expect(output).to match(/payload={:debug_args=>\[\]}/)
      expect(output).to match(/k_with_dsplat.log/)
      expect(output).to match(/payload={:debug_args=>\[\]}/)
      expect(@events).to contain_exactly(
        have_attributes(name: /i.log/, payload: { debug_args: [] }),
        have_attributes(name: /i_with_ssplat.log/, payload: { debug_args: [], id: 1, first_name: 'Joe', last_name: 'Schmoe' }),
        have_attributes(name: /i_with_dsplat.log/, payload: { debug_args: [], salutation: 'Mr.', suffix: 'Jr.' }),
        have_attributes(name: /k.log/, payload: { debug_args: [] }),
        have_attributes(name: /k_with_ssplat.log/, payload: { debug_args: [] }),
        have_attributes(name: /k_with_dsplat.log/, payload: { debug_args: [] })
      )
    end

    it 'has correct return value' do
      expect(complete_notified_klass.new.i).to eq(40)
      expect(complete_notified_klass.k).to eq(10)
    end
  end
end
