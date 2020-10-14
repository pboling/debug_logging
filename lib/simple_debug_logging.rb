# frozen_string_literal: true

# Simpler version of what the sibling DebugLogging library does.  Included as a bauble.
#
############# THIS IS A BAUBLE
############# FOR EXAMINING SEVERAL OF THE WONDERS OF RUBY
############# TO ACCOMPLISH SOMETHING PRACTICAL
############# For a more robust implementation use the gem debug_logging itself,
#############   which makes use of these same principles.
#
# Automatically log Class.method(arguments) as they are called at runtime (instance or singleton)!
#
#   Create a file `unobtrusively_logged.rb` with:
#
#     require 'simple_debug_logging'
#     class UnobtrusivelyLogged
#       def initialize(**args); end
#       def an_instance_method(*args); end
#       def self.a_class_method(*args); self; end
#       include SimpleDebugLogging.new(i_methods: %i( initialzie an_instance_method ))
#       logged :a_class_method
#     end
#
#   In an irb session:
#     >> require_relative 'unobtrusively_logged'
#     => true
#     >> UnobtrusivelyLogged.a_class_method.new.an_instance_method
#     UnobtrusivelyLogged.a_class_method() ~70156299674920@1506415414~
#     UnobtrusivelyLogged.a_class_method ~689933733604307372~ complete in 8.000002708286047e-06s ~70156299674920@1506415414~
#     UnobtrusivelyLogged#an_instance_method() ~70156299673760@1506415414~
#     UnobtrusivelyLogged#an_instance_method ~689933733604307372~ complete in 2.00001522898674e-06s ~70156299673760@1506415414~
#
# NOTE: For a more advanced version see the debug_logging gem
# NOTE: The manner this is made to work for class methods is totally different than the way this is made to work for instance methods.
# NOTE: The instance method manner of logging works on Ruby 2.0+
# NOTE: The class method manner of logging works on Ruby 2.1+

require 'benchmark'

class SimpleDebugLogging < Module
  def initialize(i_methods: nil)
    super()
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
            puts "#{self}.#{method_to_log}(#{args.map(&:inspect).join(', ')})#{invocation_id}"
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
            puts "#{self.class}##{method_to_log}(#{args.map(&:inspect).join(', ')})#{invocation_id}"
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
