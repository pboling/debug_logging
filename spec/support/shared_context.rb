DebugLogging.configuration.active_support_notifications = true

RSpec.shared_context "with example classes" do
  after do
    DebugLogging.debug_logging_configuration = DebugLogging::Configuration.new
  end

  let(:logger) { double("logger") }

  let(:simple_klass) do
    Class.new do
      class << self
        def name
          "SimpleKlass"
        end
        alias_method :to_s, :name
      end
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
    # Needs to be at the top of the class, adds `notified` class method
    extend DebugLogging::ClassNotifier
    self.debug_instance_benchmarks = true
    self.debug_add_invocation_id = false
    self.debug_ellipsis = "..."
    self.debug_last_hash_max_length = 888

    class << self
      def perform(*_args)
        42
      end

      def banana(*_args)
        77
      end
    end
  end

  class ChildSingletonClass < ParentSingletonClass
    self.debug_instance_benchmarks = false
    self.debug_add_invocation_id = true
    self.debug_ellipsis = ",,,"
    self.debug_last_hash_max_length = 777
    logged def self.snakes(*_args)
      88
    end
    logged :banana, ellipsis: "+-+-+-", args_max_length: 55
  end

  let(:parent_singleton_klass) do
    ParentSingletonClass
  end

  let(:child_singleton_klass) do
    ChildSingletonClass
  end

  let(:child_singleton_logged_klass) do
    Class.new(ChildSingletonClass) do
      class << self
        def name
          "ChildSingletonLoggedKlass"
        end
        alias_method :to_s, :name
      end
      self.debug_ellipsis = "<<<"
      logged def self.perform(*_args)
        67
      end
    end
  end

  let(:child_singleton_notified_klass) do
    Class.new(ChildSingletonClass) do
      class << self
        def name
          "ChildSingletonNotifiedKlass"
        end
        alias_method :to_s, :name
      end
      self.debug_ellipsis = ">>>"
      notified def self.perform(*_args)
        24
      end
    end
  end

  let(:child_singleton_logged_and_notified_klass) do
    Class.new(ChildSingletonClass) do
      class << self
        def name
          "ChildSingletonLoggedAndNotifiedKlass"
        end
        alias_method :to_s, :name
      end
      self.debug_ellipsis = "***"

      class << self
        def perform(*_args)
          43
        end
      end
      logged :perform
      notified :perform
    end
  end

  let(:child_singleton_logged_args_klass) do
    Class.new(ChildSingletonClass) do
      class << self
        def name
          "ChildSingletonLoggedArgsKlass"
        end
        alias_method :to_s, :name
      end
      self.debug_ellipsis = "<><><>"
      logged :snakes, args_max_length: 26, args_to_s_proc: ->(args) { args.to_s[0..27] }
    end
  end

  let(:complete_logged_klass) do
    Class.new do
      class << self
        def name
          "CompleteLoggedKlass"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `logged` class method
      extend DebugLogging::ClassLogger
      # Adds `i_logged` class method
      extend DebugLogging::InstanceLogger

      class << self
        def k
          10
        end

        def k_with_ssplat(*_args)
          20
        end

        def k_with_dsplat(**_args)
          30
        end

        def k_with_ssplat_i(*_args)
          21
        end

        def k_with_dsplat_i(**_args)
          31
        end

        def k_with_ssplat_e(*_args)
          21
        end

        def k_with_dsplat_e(**_args)
          31
        end

        def k_without_log
          0
        end
      end
      logged :k
      logged :k_with_ssplat, {class_benchmarks: false, mark_scope_exit: true}
      logged :k_with_dsplat, {class_benchmarks: false, mark_scope_exit: false}
      logged :k_with_ssplat_i, :k_with_dsplat_i, {last_hash_to_s_proc: ->(_) { "LOLiii" }}
      logged %i[k_with_ssplat_e k_with_dsplat_e], {
        last_hash_to_s_proc: lambda { |_|
                               "LOLeee"
                             },
        colorized_chain_for_class: lambda { |colorized_string|
                                     colorized_string.red
                                   },
      }

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end
      i_logged %i[i i_with_ssplat]
      i_logged [:i_with_dsplat], {
        colorized_chain_for_method: lambda { |colorized_string|
          colorized_string.red
        },
      }

      def i_without_log
        0
      end
    end
  end

  let(:complex_config_logged_klass) do
    Class.new do
      class << self
        def name
          "ComplexConfigLoggedKlass"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `logged` class method
      extend DebugLogging::ClassLogger
      # Adds `i_logged` class method
      extend DebugLogging::InstanceLogger

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
      logged :k_with_ssplat_i, :k_with_dsplat_i, {last_hash_to_s_proc: ->(_) { "LOLiii" }}
      def self.k_with_ssplat_e(*_args)
        21
      end

      def self.k_with_dsplat_e(**_args)
        31
      end
      logged %i[k_with_ssplat_e k_with_dsplat_e], {
        last_hash_to_s_proc: lambda { |_|
          "LOLeee"
        },
        colorized_chain_for_class: lambda { |colorized_string|
          colorized_string.red
        },
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

      def rattle
        88
      end

      i_logged %i[i i_with_ssplat]
      i_logged [:i_with_dsplat], {
        colorized_chain_for_method: lambda { |colorized_string|
          colorized_string.red
        },
      }
      i_logged [
        [
          :initialize, {
            log_level: :debug,
            colorized_chain_for_method: lambda { |colorized_string|
              colorized_string.red
            },
          },
        ],
        [
          :rattle, {
            log_level: :debug,
            colorized_chain_for_method: lambda { |colorized_string|
              colorized_string.blue
            },
          },
        ],
      ]
    end
  end

  let(:complete_logged_klass_no_logged_imethods) do
    Class.new do
      class << self
        def name
          "CompleteLoggedClassNoLoggedImethods"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `logged` class method
      extend DebugLogging::ClassLogger
      # Adds `i_logged` class method, but we're not going to use it in this class.
      # Just want to test that inclusion alone doesn't break anything.
      extend DebugLogging::InstanceLogger
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
      logged :k_with_ssplat_i, :k_with_dsplat_i, {last_hash_to_s_proc: ->(_) { "LOLiii" }}
      def self.k_with_ssplat_e(*_args)
        21
      end

      def self.k_with_dsplat_e(**_args)
        31
      end
      logged %i[k_with_ssplat_e k_with_dsplat_e], {
        last_hash_to_s_proc: lambda { |_|
          "LOLeee"
        },
        colorized_chain_for_class: lambda { |colorized_string|
          colorized_string.red
        },
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

      def i_without_log
        0
      end
    end
  end

  let(:complete_notified_klass) do
    Class.new do
      class << self
        def name
          "CompleteNotifiedClass"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*,
      #   except for the logged class method, which comes from extending DebugLogging::ClassLogger
      extend DebugLogging
      # Needs to be at the top of the class, adds `notified` class method
      extend DebugLogging::ClassNotifier
      # Can only be at the top of the class *if* methods are explicitly defined
      extend DebugLogging::InstanceNotifier
      i_notified [
        :i,
        [:i_with_ssplat, {id: 1, first_name: "Joe", last_name: "Schmoe"}],
        [:i_with_dsplat, {salutation: "Mr.", suffix: "Jr."}],
        [:i_with_dsplat_payload, {tags: %w[blue green]}],
        [
          :i_with_dsplat_payload_and_config,
          {
            tags: %w[yellow red],
            instance_benchmarks: true,
            add_invocation_id: true,
            error_handler_proc: lambda { |config, error, obj, method_name, *args, **kwargs|
              config.log "There was an error like #{error.class}: #{error.message} when calling #{method_name} with #{args.inspect} and #{kwargs.inspect}. Check this: #{obj.k_without_log}"
            },
          },
        ],
        [
          :i_with_dsplat_handled_error,
          {
            tags: %w[yellow red],
            instance_benchmarks: true,
            add_invocation_id: true,
            error_handler_proc: lambda { |config, error, obj, method_name, *args, **kwargs|
              config.log "There was an error like #{error.class}: #{error.message} when calling #{method_name} with #{args.inspect} and #{kwargs.inspect}. Check this: #{obj.i_without_log}"
            },
          },
        ],
      ]

      notified def self.k
        10
      end

      class << self
        # NOTE: notified could be made to work as a decorator in this context, left as an exercise for the reader.
        # notified def self.k
        #   10
        # end

        def k_with_ssplat(*_args)
          20
        end

        def k_with_dsplat(**_args)
          30
        end

        def k_with_ssplat_error(*_args)
          raise StandardError, "bad method!"
        end

        def k_with_ssplat_handled_error(*_args)
          raise StandardError, "bad method!"
        end

        def k_with_dsplat_payload(**_args)
          31
        end

        def k_with_dsplat_payload_and_config(**_args)
          32
        end

        def k_with_dsplat_handled_error(**_args)
          32
        end

        def k_without_log
          0
        end
      end

      notified :k_with_ssplat,
        :k_with_dsplat,
        :k_with_ssplat_error
      notified :k_with_dsplat_payload, {id: 2, first_name: "Bae", last_name: "Fae"}
      notified :k_with_dsplat_payload_and_config, {id: 3, first_name: "Jae", last_name: "Tae", log_level: :error}
      notified :k_with_ssplat_handled_error,
        class_benchmarks: true,
        error_handler_proc: lambda { |config, error, obj, method_name, *args|
          config.log "There was an error like #{error.class}: #{error.message} when calling #{method_name} with #{args.inspect}. Check this: #{obj.k_without_log}"
        }
      notified :k_with_dsplat_handled_error,
        class_benchmarks: true,
        error_handler_proc: lambda { |config, error, obj, method_name, *args, **kwargs|
          config.log "There was an error like #{error.class}: #{error.message} when calling #{method_name} with #{args.inspect} * #{kwargs.inspect}. Check this: #{obj.k_without_log}"
        }

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

      def i_with_dsplat_handled_error(**_args)
        raise "Black and Yellow"
      end

      def i_without_log
        0
      end
    end
  end

  let(:singleton_logged_klass) do
    Class.new do
      class << self
        def name
          "SingletonLoggedKlass"
        end
        alias_method :to_s, :name
      end
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
      logged :k_with_ssplat, :k_with_dsplat, {
        add_invocation_id: true,
        class_benchmarks: true,
        colorized_chain_for_method: ->(colorized_string) {
          colorized_string.yellow
        },
      }
      def self.k_without_log
        0
      end
    end
  end

  let(:singleton_notified_klass) do
    Class.new do
      class << self
        def name
          "SingletonNotifiedKlass"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      # Needs to be at the top of the class
      extend DebugLogging::ClassNotifier
      notified def self.k
        10
      end
      def self.k_with_ssplat(*_args)
        20
      end

      def self.k_with_dsplat(**_args)
        30
      end
      notified :k_with_ssplat, :k_with_dsplat
      def self.k_without_log
        0
      end
    end
  end

  let(:instance_logged_klass_explicit) do
    Class.new do
      class << self
        def name
          "SingletonLoggedKlassExplicit"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceLogger
      i_logged %i[i i_with_ssplat i_with_dsplat]

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end

      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_explicit) do
    Class.new do
      class << self
        def name
          "InstanceNotifiedKlassExplicit"
        end
        alias_method :to_s, :name
      end
      attr_accessor :id, :action, :msg

      def initialize(action: nil, id: nil, msg: {})
        @action = action
        @id = id
        @msg = msg
      end

      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceNotifier
      i_notified [
        :i,
        [
          :i_with_ssplat,
          {id: 1, first_name: "Joe", last_name: "Schmoe"},
        ],
        [:i_with_dsplat, {salutation: "Mr.", suffix: "Jr."}],
        [
          :i_with_instance_vars,
          {instance_variables: %i[action id msg]},
        ],
      ]

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

      def i_without_log
        0
      end
    end
  end

  let(:instance_logged_klass_dynamic) do
    Class.new do
      class << self
        def name
          "InstanceLoggedKlassDynamic"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceLogger
      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_args)
        60
      end
      # Needs to be below any methods that will want logging when using dynamic `instance_methods`
      i_logged instance_methods(false)

      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_dynamic) do
    Class.new do
      class << self
        def name
          "InstanceNotifiedKlassDynamic"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceNotifier

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_dargs)
        60
      end
      i_notified instance_methods(false)
      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_no_logged_imethods) do
    Class.new do
      class << self
        def name
          "InstanceNotifiedKlassNoLoggedImethods"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceNotifier

      def i
        40
      end

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_dargs)
        60
      end

      def i_without_log
        0
      end
    end
  end

  let(:instance_notified_klass_string_logged_imethods) do
    Class.new do
      class << self
        def name
          "InstanceNotifiedKlassStringLoggedImethods"
        end
        alias_method :to_s, :name
      end
      # adds the helper methods to the class, all are prefixed with debug_*
      extend DebugLogging
      extend DebugLogging::InstanceNotifier

      def i
        40
      end
      i_notified "i"

      def i_with_ssplat(*_args)
        50
      end

      def i_with_dsplat(**_dargs)
        60
      end

      def i_without_log
        0
      end
    end
  end
end
