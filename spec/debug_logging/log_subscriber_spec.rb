# frozen_string_literal: true

require 'spec_helper'
DebugLogging.configuration.active_support_notifications = true

RSpec.describe DebugLogging::LogSubscriber do
  include_context 'with example classes'

  before do
    @log_subscriber = described_class
    ActiveSupport::Notifications.subscribe(/log/) do |*args|
      @log_subscriber.log_event(ActiveSupport::Notifications::Event.new(*args))
    end
  end

  describe '#log_event' do
    context 'without payload override hash' do
      it 'logs the event' do
        expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
        complete_notified_klass.k_with_dsplat(a: 'a')

        expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
        expect(@log_subscriber.event.name).to match('k_with_dsplat.log')
        expect(@log_subscriber.event.payload[:config_proxy]).to match(instance_of(DebugLogging::Configuration))
        expect(@log_subscriber.event.payload[:debug_args]).to match([{ a: 'a' }])
      end
    end

    context 'with payload override hash' do
      it 'logs the event' do
        expect(complete_notified_klass.debug_config).not_to receive(:log)
        complete_notified_klass.k_with_dsplat_payload_and_config(a: 'a')

        expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
        expect(@log_subscriber.event.name).to match('k_with_dsplat_payload_and_config.log')
        expect(@log_subscriber.event.payload[:config_proxy]).to match(instance_of(DebugLogging::Configuration))
        expect(@log_subscriber.event.payload[:debug_args]).to match([{ a: 'a' }])
        expect(@log_subscriber.event.payload[:id]).to eq(3)
        expect(@log_subscriber.event.payload[:first_name]).to eq('Jae')
        expect(@log_subscriber.event.payload[:last_name]).to eq('Tae')
      end
    end

    context 'with error' do
      it 'logs the event' do
        expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
        expect do
          complete_notified_klass.k_with_ssplat_error(a: 'a')
        end.to raise_error(StandardError, 'bad method!')

        expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
        expect(@log_subscriber.event.name).to match('k_with_ssplat_error.log')
        expect(@log_subscriber.event.payload[:config_proxy]).to match(instance_of(DebugLogging::Configuration))
        expect(@log_subscriber.event.payload[:debug_args]).to match([{ a: 'a' }])
        expect(@log_subscriber.event.payload[:exception]).to match(['StandardError', 'bad method!'])
        expect(@log_subscriber.event.payload[:exception_object]).to be_a(StandardError)
      end
    end
  end
end
