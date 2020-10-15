# frozen_string_literal: true

require 'active_support/log_subscriber'

module DebugLogging
  class LogSubscriber < ActiveSupport::LogSubscriber
    class << self
      attr_accessor :event
    end
    attach_to :log

    EVENT_FORMAT_STRING = '%<name>s (%<duration>.3f secs) start=%<time>s end=%<end>s payload=%<payload>s'

    def self.log_event(event)
      @event = event
      if event.payload && event.payload[:exception_object]
        exception = event.payload[:exception_object]
        "#{event.name} [ERROR] : \n#{exception.class} : #{exception.message}\n" + exception.backtrace.join("\n")
      end
      format(EVENT_FORMAT_STRING, event_to_format_options(event))
    end

    # @param [ActiveSupport::Notifications::Event]
    # @return [Hash]
    def self.event_to_format_options(event)
      {
        name: event.name,
        duration: Rational(event.duration, 1000).to_f,
        time: event.time,
        end: event.end,
        payload: event.payload
      }
    end
  end
end
