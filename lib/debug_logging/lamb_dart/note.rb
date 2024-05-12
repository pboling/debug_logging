module DebugLogging
  module LambDart
    class Note < Base
      attr_reader :debug_args

      def initialize(...)
        super do |proxy|
          subscribe(proxy)
        end
        @debug_args = kwargs.empty? ? args : args + [kwargs]
      end

      private

      def subscribe(proxy)
        ActiveSupport::Notifications.subscribe(
          DebugLogging::ArgumentPrinter.debug_event_name_to_s(decorated_method: decorated_method),
        ) do |*subscribe_args|
          proxy.log do
            DebugLogging::LogSubscriber.log_event(ActiveSupport::Notifications::Event.new(*subscribe_args))
          end
        end
      end

      def proxy_ref
        is_class ? "kn" : "inm"
      end
    end
  end
end
