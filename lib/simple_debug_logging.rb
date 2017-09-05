# Simpler version of what the sibling DebugLogging library does.  Included as a bauble.
#
# Automatically log Class.method(arguments) as they are called at runtime!
#
# NOTE: For a more advanced version see the debug_logging gem
# NOTE: The manner this is made to work for class methods is totally different than the way this is made to work for instance methods.
# NOTE: The instance method manner of logging works on Ruby 2.0+
# NOTE: The class method manner of logging works on Ruby 2.1+
class SimpleDebugLogging < Module
  def initialize(i_methods: nil)
    @instance_methods_to_log = Array(i_methods) if i_methods
  end
  def included(base)
    instance_method_logger = InstanceMethodLoggerModulizer.to_mod(@instance_methods_to_log)
    base.send(:prepend, instance_method_logger)
    base.send(:extend, ClassMethodLogger)
  end
  module ClassMethodLogger
    def logged(*methods_to_log)
      methods_to_log.each do |method_to_log|
        original_method = method(method_to_log)
        (class << self; self; end).class_eval do
          define_method(method_to_log.to_sym) do |*args|
            method_return_value = nil
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if args
            puts "#{self}.#{method_to_log}(#{args.map {|x| x.inspect}.join(", ")})#{invocation_id}"
            elapsed = Benchmark.realtime do
              method_return_value = original_method.call(*args)
            end
            puts "#{self}.#{method_to_log} ~#{args.hash}~ complete in #{elapsed}s#{invocation_id}"
            method_return_value
          end
        end
      end
    end
  end
  module InstanceMethodLoggerModulizer
    def self.to_mod(methods_to_log = [])
      Module.new do
        Array(methods_to_log).each do |method_to_log|
          define_method(method_to_log.to_sym) do |*args, &block|
            method_return_value = nil
            invocation_id = " ~#{args.object_id}@#{Time.now.to_i}~" if args
            puts "#{self.class}##{method_to_log}(#{args.map {|x| x.inspect}.join(", ")})#{invocation_id}"
            elapsed = Benchmark.realtime do
              method_return_value = super(*args, &block)
            end
            puts "#{self.class}##{method_to_log} ~#{args.hash}~ complete in #{elapsed}s#{invocation_id}"
            method_return_value
          end
        end
      end
    end
  end
end
