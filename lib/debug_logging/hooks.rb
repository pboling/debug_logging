require "debug_logging/errors"
require "timeout"

module DebugLogging
  module Hooks
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def self.extend(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods
      def debug_time_box(time, *names, &blk)
        names.each do |name|
          meth = instance_method(name)
          define_method(name) do |*args, &block|
            Timeout.timeout(time) do
              meth.bind_call(self, *args, &block)
            end
          rescue Timeout::Error
            error_args = [TimeoutError, "execution expired", caller]
            raise(*error_args) unless blk

            instance_exec(*error_args, &blk)
          end
        end
      end

      def debug_rescue_on_fail(*names, &blk)
        unless blk
          raise NoBlockGiven,
            ".rescue_on_fail must be called with a block",
            caller
        end
        names.each do |name|
          meth = instance_method(name)
          define_method(name) do |*args, &block|
            meth.bind_call(self, *args, &block)
          rescue StandardError => e
            instance_exec(e, &blk)
          end
        end
      end

      def debug_before(*names, &blk)
        unless blk
          raise NoBlockGiven,
            ".before must be called with a block",
            caller
        end
        names.each do |name|
          meth = instance_method(name)
          define_method(name) do |*args, &block|
            instance_exec(name, *args, block, &blk)
            meth.bind_call(self, *args, &block)
          end
        end
      end

      def debug_after(*names, &blk)
        unless blk
          raise NoBlockGiven,
            ".after must be called with a block",
            caller
        end
        names.each do |name|
          meth = instance_method(name)
          define_method(name) do |*args, &block|
            result = meth.bind_call(self, *args, &block)
            instance_exec(result, &blk)
          end
        end
      end
    end
  end
end
