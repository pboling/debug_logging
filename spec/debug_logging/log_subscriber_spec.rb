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

      context 'with handling' do
        it 'logs the error using the proc configured' do
          # Doesn't call the config for the class, but the custom config for the method
          expect(complete_notified_klass.debug_config).to_not receive(:log)
          output = ''
          expect do
            output = capture('stdout') do
              complete_notified_klass.k_with_ssplat_handled_error(a: 'a')
            end
          end.not_to raise_error

          expect(@log_subscriber.event).to be_a_kind_of(ActiveSupport::Notifications::Event)
          expect(@log_subscriber.event.name).to match('k_with_ssplat_handled_error.log')
          expect(@log_subscriber.event.payload[:config_proxy]).to match(instance_of(DebugLogging::Configuration))
          expect(@log_subscriber.event.payload[:debug_args]).to match([{ a: 'a' }])
          expect(@log_subscriber.event.payload[:exception]).to be_nil
          expect(@log_subscriber.event.payload[:exception_object]).to be_nil

          expect(output).to match("DEBUG -- : There was an error like StandardError: bad method! when 0")
          expect(output).to match(/DEBUG -- : k_with_ssplat_handled_error\.log \(\d.\d{3} secs\) start=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} end=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} args=\(\*\*\{:a=>"a"\}\) payload=\{\}/)
        end
      end
    end
  end
end
