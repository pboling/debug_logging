# frozen_string_literal: true

DebugLogging.configuration.active_support_notifications = true

RSpec.shared_context 'with example classes' do
  after do
    DebugLogging.debug_logging_configuration = DebugLogging::Configuration.new
  end

  let(:logger) { double('logger') }

  let(:simple_klass) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
    end
  end

  class ParentSingletonClass
    # adds the helper methods to the class, all are prefixed with debug_*,
    #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
    extend DebugLogging
    # Needs to be at the top of the class, adds `logged` class method
    extend DebugLogging::ClassLogger
    # Needs to be at the top of the class, adds `notifies` class method
    extend DebugLogging::ClassNotifier
    self.debug_instance_benchmarks = true
    self.debug_add_invocation_id = false
    self.debug_ellipsis = '...'
    self.debug_last_hash_max_length = 888

    def self.perform(*_args)
      42
    end

    def self.banana(*_args)
      77
    end
  end

  class ChildSingletonClass < ParentSingletonClass
    self.debug_instance_benchmarks = false
    self.debug_add_invocation_id = true
    self.debug_ellipsis = ',,,'
    self.debug_last_hash_max_length = 777
    logged def self.snakes(*_args)
      88
    end
    logged :banana, ellipsis: '+-+-+-', args_max_length: 55
  end

  let(:parent_singleton_klass) do
    ParentSingletonClass
  end

  let(:child_singleton_klass) do
    ChildSingletonClass
  end

  let(:child_singleton_logged_klass) do
    Class.new(ChildSingletonClass) do
      self.debug_ellipsis = '<<<'
      logged def self.perform(*_args)
        67
      end
    end
  end

  let(:child_singleton_notified_klass) do
    Class.new(ChildSingletonClass) do
      self.debug_ellipsis = '>>>'
      notifies def self.perform(*_args)
        24
      end
    end
  end

  let(:child_singleton_logged_and_notified_klass) do
    Class.new(ChildSingletonClass) do
      self.debug_ellipsis = '***'
      def self.perform(*_args)
        43
      end
      logged :perform
      notifies :perform
    end
  end

  let(:child_singleton_logged_args_klass) do
    Class.new(ChildSingletonClass) do
      self.debug_ellipsis = '<><><>'
      logged :snakes, args_max_length: 26, args_to_s_proc: ->(args) { args.to_s[0..27] }
    end
  end

  let(:complete_logged_klass) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `logged` class method
      extend DebugLogging::ClassLogger
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: %i[i i_with_ssplat])
      include DebugLogging::InstanceLogger.new(i_methods: [:i_with_dsplat], config: { colorized_chain_for_method: lambda { |colorized_string|
                                                                                                                    colorized_string.red
                                                                                                                  } })
      logged def self.k
        10
      end
      def self.k_with_ssplat(*_args)
        20
      end

      def self.k_with_dsplat(**_args)
        30
      end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_with_ssplat_i(*_args)
        21
      end

      def self.k_with_dsplat_i(**_args)
        31
      end
      logged :k_with_ssplat_i, :k_with_dsplat_i, { last_hash_to_s_proc: ->(_) { 'LOLiii' } }
      def self.k_with_ssplat_e(*_args)
        21
      end

      def self.k_with_dsplat_e(**_args)
        31
      end
      logged %i[k_with_ssplat_e k_with_dsplat_e], { last_hash_to_s_proc: lambda { |_|
                                                                           'LOLeee'
                                                                         }, colorized_chain_for_class: lambda { |colorized_string|
                                                                                                         colorized_string.red
                                                                                                       } }
      def self.k_without_log
        0
      end

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end

      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log
        0
      end
    end
  end

  let(:complete_notified_klass) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `notifies` class method
      extend DebugLogging::ClassNotifier
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceNotifier.new(i_methods: [
                                                   :i,
                                                   [:i_with_ssplat, { id: 1, first_name: 'Joe', last_name: 'Schmoe' }],
                                                   [:i_with_dsplat, { salutation: 'Mr.', suffix: 'Jr.' }],
                                                   [:i_with_dsplat_payload, { tags: %w[blue green] }],
                                                   [:i_with_dsplat_payload_and_config,
                                                    { tags: %w[yellow red], add_invocation_id: true }]
                                                 ])
      notifies def self.k
        10
      end

      def self.k_with_ssplat(*_args)
        20
      end

      def self.k_with_dsplat(**_args)
        30
      end

      def self.k_with_ssplat_error(*_args)
        raise StandardError, 'bad method!'
      end

      def self.k_with_ssplat_handled_error(*_args)
        raise StandardError, 'bad method!'
      end

      def self.k_with_dsplat_payload(**_args)
        31
      end

      def self.k_with_dsplat_payload_and_config(**_args)
        32
      end

      notifies :k_with_ssplat,
               :k_with_dsplat,
               :k_with_ssplat_error
      notifies :k_with_dsplat_payload, { id: 2, first_name: 'Bae', last_name: 'Fae' }
      notifies :k_with_dsplat_payload_and_config, { id: 3, first_name: 'Jae', last_name: 'Tae', log_level: :error }
      notifies :k_with_ssplat_handled_error, error_handler_proc: ->(config, error, obj) {
        config.log "There was an error like #{error.class}: #{error.message} when #{obj.k_without_log}"
      }

      def self.k_without_log
        0
      end

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end

      def i_with_dsplat_payload(**_args)
        61
      end

      def i_with_dsplat_payload_and_config(**_args)
        62
      end

      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log
        0
      end
    end
  end

  let(:singleton_logged_klass) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Needs to be at the top of the class
      extend DebugLogging::ClassLogger
      logged def self.k
        10
      end
      def self.k_with_ssplat(*_args)
        20
      end

      def self.k_with_dsplat(**_args)
        30
      end
      logged :k_with_ssplat, :k_with_dsplat
      def self.k_without_log
        0
      end
    end
  end

  let(:singleton_notified_klass) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Needs to be at the top of the class
      extend DebugLogging::ClassNotifier
      notifies def self.k
        10
      end
      def self.k_with_ssplat(*_args)
        20
      end

      def self.k_with_dsplat(**_args)
        30
      end
      notifies :k_with_ssplat, :k_with_dsplat
      def self.k_without_log
        0
      end
    end
  end

  let(:instance_logged_klass_explicit) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceLogger.new(i_methods: %i[i i_with_ssplat i_with_dsplat])
      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end

      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_explicit) do
    Class.new do
      attr_accessor :id, :action, :msg

      def initialize(action: nil, id: nil, msg: {})
        @action = action
        @id = id
        @msg = msg
      end

      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Can only be at the top of the class *if* methods are explicitly defined
      include DebugLogging::InstanceNotifier.new(i_methods: [:i,
                                                             [:i_with_ssplat,
                                                              { id: 1, first_name: 'Joe', last_name: 'Schmoe' }],
                                                             [:i_with_dsplat, { salutation: 'Mr.', suffix: 'Jr.' }],
                                                             [:i_with_instance_vars,
                                                              { instance_variables: %i[action id msg] }]])
      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end

      def i_with_instance_vars
        70
      end

      # Needs to be below any methods that will want logging when using self.instance_methods(false)
      # include DebugLogging::InstanceLogger.new(i_methods: self.instance_methods(false))
      def i_without_log
        0
      end
    end
  end

  let(:instance_logged_klass_dynamic) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end
      # Needs to be below any methods that will want logging when dynamic
      include DebugLogging::InstanceLogger.new(i_methods: instance_methods(false))
      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_dynamic) do
    Class.new do
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end
      # Needs to be below any methods that will want logging when dynamic
      include DebugLogging::InstanceNotifier.new(i_methods: instance_methods(false))
      def i_without_log
        0
      end
    end
  end
end
