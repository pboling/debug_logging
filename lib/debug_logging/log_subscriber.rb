require "active_support"
require "active_support/log_subscriber"

module DebugLogging
  class LogSubscriber < ActiveSupport::LogSubscriber
    EXCLUDE_FROM_PAYLOAD = %i[debug_args config_proxy].freeze
    extend DebugLogging::ArgumentPrinter

    class << self
      attr_accessor :event
    end
    attach_to :log

    EVENT_FORMAT_STRING = "%<name>s (%<duration>.3f secs) start=%<time>s end=%<end>s args=%<args>s payload=%<payload>s"

    def self.log_event(event)
      @event = event
      if event.payload && event.payload[:exception_object]
        exception = event.payload[:exception_object]
        "#{event.name} [ERROR] : \n#{exception.class} : #{exception.message}\n" + exception.backtrace.join("\n")
      else
        format(EVENT_FORMAT_STRING, event_to_format_options(event))
      end
    end

    # @param [ActiveSupport::Notifications::Event]
    # @return [Hash]
    def self.event_to_format_options(event)
      args = event.payload[:debug_args]
      config_proxy = event.payload[:config_proxy]
      payload = event.payload.reject { |k, _| EXCLUDE_FROM_PAYLOAD.include?(k) }
      {
        name: event.name,
        duration: Rational(event.duration, 1000).to_f,
        time: debug_time_to_s(event.time),
        end: debug_time_to_s(event.end),
        args: debug_signature_to_s(args: args, config_proxy: config_proxy),
        payload: debug_payload_to_s(payload: payload, config_proxy: config_proxy),
      }
    end
  end
end
