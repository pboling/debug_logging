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
        expect(@log_subscriber.event.payload).to eq({ debug_args: [{ a: 'a' }] })
      end
    end

    context 'with payload override hash' do
      it 'logs the event' do
        expect(complete_notified_klass.debug_config).to_not receive(:log)
        complete_notified_klass.k_with_dsplat_payload(a: 'a')

        expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
        expect(@log_subscriber.event.name).to match('k_with_dsplat_payload.log')
        expect(@log_subscriber.event.payload).to eq({ debug_args: [{ a: 'a' }], id: 1, first_name: 'Joe', last_name: 'Schmoe' })
      end
    end

    context 'with error' do
      it 'logs the event' do
        expect(complete_notified_klass.debug_config).to receive(:log).once.and_call_original
        expect do
          complete_notified_klass.k_with_ssplat_error(a: 'a')
        end.to raise_error(StandardError)

        expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
        expect(@log_subscriber.event.name).to match('k_with_ssplat_error.log')
        expect(@log_subscriber.event.payload).to include({ debug_args: [{ a: 'a' }], exception: ['StandardError', 'bad method!'] })
      end
    end
  end
end
