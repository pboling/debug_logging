require "forwardable"

module DebugLogging
  module LambDart
    class Base
      extend Forwardable

      attr_reader :instance, # For ClassLogger, this will be the same as klass
        :klass,
        :is_class,
        :config_proxy,
        :method_payload,
        :args,
        :kwargs,
        :scope_term,
        :decorated_method

      def_delegator :@config_proxy, :error_handler_proc

      def initialize(instance: nil, klass: nil, method_config_opts:, method_payload:, args:, kwargs:, decorated_method:)
        @instance = instance || klass
        @klass = klass || instance.class
        @method_payload = method_payload
        @args = args
        @kwargs = kwargs
        @decorated_method = decorated_method
        @is_class = (self.klass == self.instance)
        @scope_term = is_class ? "class" : "instance"
        @config_proxy = DebugLogging::Util.config_proxy_finder(
          scope: self.klass,
          config_opts: method_config_opts,
          method_name: self.decorated_method,
          proxy_ref:,
        ) do |proxy|
          yield proxy if block_given?
        end
      end

      private

      def proxy_ref
        raise "#{self.class}##{__method__} is not defined, please fix!"
      end
    end
  end
end
