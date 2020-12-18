# frozen_string_literal: true

require 'spec_helper'
DebugLogging.configuration.active_support_notifications = true

RSpec.describe DebugLogging::Configuration do
  include_context 'with example classes'
  context 'config' do
    context 'global inherited config' do
      context 'with block' do
        context 'instance logging' do
          before do
            DebugLogging.configure do |config|
              config.instance_benchmarks = true
              config.add_invocation_id = true # invocation id allows you to identify a method call uniquely in a log
            end
            instance_logged_klass_explicit.debug_instance_benchmarks = false
            instance_logged_klass_explicit.debug_add_invocation_id = false
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            allow(instance_logged_klass_explicit).to receive(:debug_log) { logger }
          end

          it 'keeps separate configs' do
            expect(DebugLogging.configuration.instance_benchmarks).to eq(true)
            expect(DebugLogging.configuration.add_invocation_id).to eq(true)
            expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(true)
            expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(true)
            expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(false)
            expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(false)
          end

          it 'uses separate configs' do
            # No options hashes on either, so same methods use class-level config
            instance_logged_klass_dynamic.debug_add_invocation_id = false
            instance_logged_klass_explicit.debug_add_invocation_id = true
            expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(true)
            expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(false)
            expect(instance_logged_klass_dynamic.debug_config).to receive(:log).twice.and_call_original
            expect(instance_logged_klass_explicit.debug_config).to receive(:log).once.and_call_original
            output = capture('stdout') do
              instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
              instance_logged_klass_explicit.new.i_with_ssplat('z', 1, true, ['y', 2, false], { t: :t, p: :p })
            end
            expect(output).to match(Regexp.escape('#i_with_ssplat("a", 1, true, ["b", 2, false], {:c=>:d, :e=>:f}) debug: {}'))
            expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)$/)
            expect(output).to match(/#i_with_ssplat\("z", 1, true, \["y", 2, false\], {:t=>:t, :p=>:p}\) ~\d+@.+~ debug: {}\Z/)
            expect(output).not_to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          end

          it 'has correct return value' do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                   { c: :d, e: :f })).to eq(50)
            expect(instance_logged_klass_explicit.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                    { c: :d, e: :f })).to eq(50)
            expect(instance_logged_klass_dynamic.new.i_with_dsplat(c: :d, e: :f)).to eq(60)
            expect(instance_logged_klass_explicit.new.i_with_dsplat(c: :d, e: :f)).to eq(60)
          end
        end

        context 'instance notification' do
          before do
            DebugLogging.configure do |config|
              config.active_support_notifications = true
            end
          end

          it 'notifies' do
            output = capture('stdout') do
              instance_notified_klass_explicit.new.i
              instance_notified_klass_explicit.new.i_with_ssplat
              instance_notified_klass_explicit.new.i_with_dsplat
              instance_notified_klass_explicit.new(action: 'Update', id: 1,
                                                   msg: { greeting: 'hi' }).i_with_instance_vars
            end
            expect(output).to match(/i.log/)
            expect(output).to match(Regexp.escape('args=() payload={}'))
            expect(output).to match(/i_with_ssplat.log/)
            expect(output).to match(/payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}/)
            expect(output).to match(/i_with_dsplat.log/)
            expect(output).to match(/payload={:salutation=>"Mr.", :suffix=>"Jr."}/)
            expect(output).to match(/i_with_instance_vars.log/)
            expect(output).to match(/payload={:action=>"Update", :id=>1, :msg=>{:greeting=>"hi"}}/)
          end
        end

        context 'class logging' do
          before do
            skip_for(engine: 'ruby', versions: ['2.0.0'],
                     reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
            DebugLogging.configure do |config|
              config.class_benchmarks = true
              config.add_invocation_id = false # invocation id allows you to identify a method call uniquely in a log
            end
            complete_logged_klass.debug_class_benchmarks = false
            complete_logged_klass.debug_add_invocation_id = true
          end

          it 'keeps separate configs' do
            expect(DebugLogging.configuration.class_benchmarks).to eq(true)
            expect(DebugLogging.configuration.add_invocation_id).to eq(false)
            expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
            expect(singleton_logged_klass.debug_add_invocation_id).to eq(false)
            expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
            expect(complete_logged_klass.debug_add_invocation_id).to eq(true)
          end

          it 'uses separate configs' do
            output = capture('stdout') do
              singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
              complete_logged_klass.k_with_ssplat('z', 1, true, ['y', 2, false], { t: :t, p: :p })
            end
            expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) debug: \{\}/)
            expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)/)
            expect(output).to match(/\.k_with_ssplat\("z", 1, true, \["y", 2, false\], {:t=>:t, :p=>:p}\) ~\d+@.+~ debug: \{\}\Z/)
            expect(output).not_to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          end

          it 'has correct return value' do
            expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
            expect(complete_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          end
        end

        context 'class notification' do
          before do
            DebugLogging.configure do |config|
              config.active_support_notifications = true
            end
          end

          it 'notifies' do
            output = capture('stdout') do
              complete_notified_klass.new.i
              complete_notified_klass.new.i_with_ssplat
              complete_notified_klass.new.i_with_dsplat
              complete_notified_klass.k
              complete_notified_klass.k_with_ssplat
              complete_notified_klass.k_with_dsplat
            end
            expect(output).to match(/i.log/)
            expect(output).to match(Regexp.escape('args=() payload={}'))
            expect(output).to match(/i_with_ssplat.log/)
            expect(output).to match(/payload={:id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}/)
            expect(output).to match(/i_with_dsplat.log/)
            expect(output).to match(/payload={:salutation=>"Mr.", :suffix=>"Jr."}/)
            expect(output).to match(/k.log/)
            expect(output).to match(/payload={}/)
            expect(output).to match(/k_with_ssplat.log/)
            expect(output).to match(/payload={}/)
            expect(output).to match(/k_with_dsplat.log/)
            expect(output).to match(/payload={}/)
          end
        end
      end
    end

    context 'per class config' do
      context 'inheritance' do
        before do
          parent_singleton_klass.debug_args_max_length = 999
          # instantiate child_singleton_logged_klass before setting debug_args_max_length,
          #   so it won't inherit that config, while the other children will
          child_singleton_logged_klass
          child_singleton_klass.debug_args_max_length = 50
        end

        after do
          parent_singleton_klass.debug_args_max_length = 1000
          child_singleton_klass.debug_args_max_length = 1000
        end

        it 'keeps separate configs' do
          expect(parent_singleton_klass.debug_instance_benchmarks).to eq(true)
          expect(parent_singleton_klass.debug_add_invocation_id).to eq(false)
          expect(parent_singleton_klass.debug_ellipsis).to eq('...')
          expect(parent_singleton_klass.debug_args_max_length).to eq(999)
          expect(parent_singleton_klass.debug_last_hash_max_length).to eq(888)

          expect(child_singleton_klass.debug_instance_benchmarks).to eq(false)
          expect(child_singleton_klass.debug_add_invocation_id).to eq(true)
          expect(child_singleton_klass.debug_ellipsis).to eq(',,,')
          expect(child_singleton_klass.debug_args_max_length).to eq(50)
          expect(child_singleton_klass.debug_last_hash_max_length).to eq(777)

          expect(child_singleton_logged_klass.debug_instance_benchmarks).to eq(false)
          expect(child_singleton_logged_klass.debug_add_invocation_id).to eq(true)
          expect(child_singleton_logged_klass.debug_ellipsis).to eq('<<<')
          expect(child_singleton_logged_klass.debug_args_max_length).to eq(1000)
          expect(child_singleton_logged_klass.debug_last_hash_max_length).to eq(777)

          expect(child_singleton_notified_klass.debug_instance_benchmarks).to eq(false)
          expect(child_singleton_notified_klass.debug_add_invocation_id).to eq(true)
          expect(child_singleton_notified_klass.debug_ellipsis).to eq('>>>')
          expect(child_singleton_notified_klass.debug_args_max_length).to eq(50)
          expect(child_singleton_notified_klass.debug_last_hash_max_length).to eq(777)

          expect(child_singleton_logged_and_notified_klass.debug_instance_benchmarks).to eq(false)
          expect(child_singleton_logged_and_notified_klass.debug_add_invocation_id).to eq(true)
          expect(child_singleton_logged_and_notified_klass.debug_ellipsis).to eq('***')
          expect(child_singleton_logged_and_notified_klass.debug_args_max_length).to eq(50)
          expect(child_singleton_logged_and_notified_klass.debug_last_hash_max_length).to eq(777)
        end

        it 'uses separate configs' do
          allow(parent_singleton_klass).to receive(:banana).and_call_original
          allow(child_singleton_klass).to receive(:banana).and_call_original
          output = capture('stdout') do
            # ParentSingletonClass class is configured to not log anything.
            expect(parent_singleton_klass.perform('a', 3, true, ['b', 2, false], { j: :k, l: :m })).to eq(42)
            expect(parent_singleton_klass.banana('a', 3, true, ['b', 2, false], { j: :k, l: :m })).to eq(77)

            # ChildSingletonClass is configured to log snakes and banana, but not perform
            expect(child_singleton_klass.snakes('abcdefghijklmnopqrstuvwxyz' * 3)).to eq(88)
            expect(child_singleton_klass.banana('abcdefghijklmnopqrstuvwxyz' * 3)).to eq(77)
            expect(child_singleton_klass.perform('z', 2, true, ['z', 2, false], { f: :g, h: :i })).to eq(42)

            expect(child_singleton_logged_klass.perform('y', 2, true, ['y', 2, false], { n: :o, p: :q })).to eq(67)
            expect(child_singleton_notified_klass.perform('x', 3, true, ['x', 2, false], { j: :k, l: :m })).to eq(24)
            expect(child_singleton_logged_and_notified_klass.perform('r', 4, true, ['u', 2, false], { a: :b, c: :d })).to eq(43)
          end
          expect(output).not_to match('ParentSingletonClass')
          expect(output).not_to match("ChildSingletonClass\.perform")
          expect(output).to match(/DEBUG -- : ChildSingletonClass\.snakes\("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwx,,,\) ~\d+@.+~ debug: \{\}$/)
          expect(output).to match(/DEBUG -- : ChildSingletonClass\.banana\("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabc\+-\+-\+-\) ~\d+@.+~ debug: \{\}$/)
          expect(output).to match(/DEBUG -- : #<.+>\.perform\("y", 2, true, \["y", 2, false\], {:n=>:o, :p=>:q}\) ~\d+@.+~ debug: \{\}$/)
          expect(output).to match(/DEBUG -- : perform\.log \(\d.\d{3} secs\) start=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} end=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} args=\("x", 3, true, \["x", 2, false\], \{:j=>:k, :l=>:m\}\) payload=\{\}/)
          expect(output).to match(/DEBUG -- : #<.+>\.perform\("r", 4, true, \["u", 2, false\], {:a=>:b, :c=>:d}\) ~\d+@.+~ debug: \{\}$/)
          expect(output).to match(/DEBUG -- : perform\.log \(\d.\d{3} secs\) start=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} end=\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4} args=\("r", 4, true, \["u", 2, false\], \{:a=>:b, :c=>:d\}\) payload=\{\}/)

          expect(parent_singleton_klass).to have_received(:banana).once
          expect(child_singleton_klass).to have_received(:banana).once
        end

        it 'can override configs' do
          output = capture('stdout') do
            expect(child_singleton_logged_args_klass.snakes('abcdefghijklmnopqrstuvwxyz' * 3)).to eq(88)
          end
          expect(output).to match(/DEBUG -- : #<.+>\.snakes\(\["abcdefghijklmnopqrstuvwxy<><><>\) ~\d+@.+~ debug: \{\}$/)
        end
      end

      context 'instance logging' do
        before do
          instance_logged_klass_dynamic.debug_instance_benchmarks = true
          instance_logged_klass_dynamic.debug_add_invocation_id = false
          instance_logged_klass_explicit.debug_instance_benchmarks = false
          instance_logged_klass_explicit.debug_add_invocation_id = true
        end

        it 'keeps separate configs' do
          expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(true)
          expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(false)
          expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(false)
          expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(true)
        end

        it 'uses separate configs' do
          output = capture('stdout') do
            instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            instance_logged_klass_explicit.new.i_with_ssplat('z', 1, true, ['y', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) debug: \{\}/)
          expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)/)
          expect(output).to match(/#i_with_ssplat\("z", 1, true, \["y", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~ debug: \{\}\Z/)
          expect(output).not_to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
        end

        it 'has correct return value' do
          expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                 { c: :d, e: :f })).to eq(50)
          expect(instance_logged_klass_explicit.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                  { c: :d, e: :f })).to eq(50)
        end
      end

      context 'class logging' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          singleton_logged_klass.debug_class_benchmarks = true
          singleton_logged_klass.debug_add_invocation_id = false
          complete_logged_klass.debug_class_benchmarks = false
          complete_logged_klass.debug_add_invocation_id = true
        end

        it 'keeps separate configs' do
          expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
          expect(singleton_logged_klass.debug_add_invocation_id).to eq(false)
          expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
          expect(complete_logged_klass.debug_add_invocation_id).to eq(true)
        end

        it 'uses separate configs' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            complete_logged_klass.k_with_ssplat('z', 1, true, ['y', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) debug: \{\}/)
          expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)/)
          expect(output).to match(/\.k_with_ssplat\("z", 1, true, \["y", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~ debug: \{\}\Z/)
          expect(output).not_to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          expect(complete_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
        end
      end
    end

    context 'per method config' do
      let(:instance_logged_klass_explicit) do
        Class.new do
          # adds the helper methods to the class, all are prefixed with debug_*
          extend DebugLogging
          self.debug_instance_benchmarks = true
          self.debug_add_invocation_id = true
          # Includes a new anonymous module each time, so can include multiple times, each with a different config!
          include DebugLogging::InstanceLogger.new(i_methods: [:i], config: { instance_benchmarks: false })
          include DebugLogging::InstanceLogger.new(i_methods: [:i_with_ssplat], config: { add_invocation_id: false })
          include DebugLogging::InstanceLogger.new(i_methods: [:i_with_dsplat],
                                                   config: { instance_benchmarks: false, add_invocation_id: false })
          def i
            40
          end

          def i_with_ssplat(*_args)
            50
          end

          def i_with_dsplat(**_args)
            60
          end

          def i_without_customization
            0
          end

          def i_without_log
            0
          end
        end
      end

      let(:instance_logged_klass_dynamic) do
        Class.new do
          # adds the helper methods to the class, all are prefixed with debug_*
          extend DebugLogging
          self.debug_instance_benchmarks = false
          self.debug_add_invocation_id = false
          def i
            40
          end

          def i_with_ssplat(*_args)
            50
          end

          def i_with_dsplat(**_args)
            60
          end
          # A bit redundant - but you can override the class settings above,
          #   which would apply to singleton and instance methods for this class,
          #   for all *instance* methods, like this:
          include DebugLogging::InstanceLogger.new(i_methods: instance_methods(false),
                                                   config: { add_invocation_id: true })
          def i_without_log
            0
          end
        end
      end
      let(:double_trouble) do
        Class.new do
          # adds the helper methods to the class, all are prefixed with debug_*
          extend DebugLogging
          extend DebugLogging::ClassLogger
          self.debug_instance_benchmarks = false
          self.debug_add_invocation_id = false
          # rubocop:disable Lint/ConstantDefinitionInBlock
          LOG_C_W_CONFIG = %i[double_trouble double_trouble! double_trouble? _double_trouble].freeze
          LOG_C_WO_CONFIG = %i[uses_class_config uses_class_config! uses_class_config? _uses_class_config].freeze
          LOG_I_W_CONFIG = %i[double_trouble double_trouble! double_trouble? _double_trouble].freeze
          LOG_I_WO_CONFIG = %i[uses_class_config uses_class_config! uses_class_config? _uses_class_config].freeze
          # rubocop:enable Lint/ConstantDefinitionInBlock
          class << self
            def uses_class_config
              'config is c_pointer'
            end

            def uses_class_config!
              'config is c_pointer'
            end

            def uses_class_config?
              'config is c_pointer'
            end

            def _uses_class_config
              'config is c_pointer'
            end

            def double_trouble
              'config is k_pointer'
            end

            def double_trouble!
              'config is k_pointer'
            end

            def double_trouble?
              'config is k_pointer'
            end

            def _double_trouble
              'config is k_pointer'
            end
          end
          logged LOG_C_W_CONFIG, { add_invocation_id: false, instance_benchmarks: true } # log the class method ^
          logged LOG_C_WO_CONFIG
          def uses_class_config
            'config is c_pointer'
          end

          def uses_class_config!
            'config is c_pointer'
          end

          def uses_class_config?
            'config is c_pointer'
          end

          def _uses_class_config
            'config is c_pointer'
          end

          def double_trouble
            'config is i_pointer'
          end

          def double_trouble!
            'config is i_pointer'
          end

          def double_trouble?
            'config is i_pointer'
          end

          def _double_trouble
            'config is i_pointer'
          end
          include DebugLogging::InstanceLogger.new(i_methods: LOG_I_WO_CONFIG)
          include DebugLogging::InstanceLogger.new(i_methods: LOG_I_W_CONFIG,
                                                   config: { add_invocation_id: true, instance_benchmarks: true })
        end
      end

      context 'instance and class logging' do
        let(:instance) { double_trouble.new }

        it 'lazily initializes method level configs' do
          c_pointer = described_class.config_pointer('kl', :uses_class_config)
          c_pointer_bang = described_class.config_pointer('kl', :uses_class_config!)
          c_pointer_q = described_class.config_pointer('kl', :uses_class_config?)
          c_pointer_u = described_class.config_pointer('kl', :_uses_class_config)
          k_pointer = described_class.config_pointer('kl', :double_trouble)
          k_pointer_bang = described_class.config_pointer('kl', :double_trouble!)
          k_pointer_q = described_class.config_pointer('kl', :double_trouble?)
          k_pointer_u = described_class.config_pointer('kl', :_double_trouble)
          ic_pointer = described_class.config_pointer('ilm', :uses_class_config)
          ic_pointer_bang = described_class.config_pointer('ilm', :uses_class_config!)
          ic_pointer_q = described_class.config_pointer('ilm', :uses_class_config?)
          ic_pointer_u = described_class.config_pointer('ilm', :_uses_class_config)
          i_pointer = described_class.config_pointer('ilm', :double_trouble)
          i_pointer_bang = described_class.config_pointer('ilm', :double_trouble!)
          i_pointer_q = described_class.config_pointer('ilm', :double_trouble?)
          i_pointer_u = described_class.config_pointer('ilm', :_double_trouble)

          expect(double_trouble.instance_variable_get(c_pointer)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(c_pointer_bang)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(c_pointer_q)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(c_pointer_u)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(k_pointer)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(k_pointer_bang)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(k_pointer_q)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(k_pointer_u)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(ic_pointer)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(ic_pointer_bang)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(ic_pointer_q)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(ic_pointer_u)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(i_pointer)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(i_pointer_bang)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(i_pointer_q)).to be_nil # not initialized yet
          expect(double_trouble.instance_variable_get(i_pointer_u)).to be_nil # not initialized yet

          double_trouble.uses_class_config
          double_trouble.uses_class_config!
          double_trouble.uses_class_config?
          double_trouble._uses_class_config
          double_trouble.double_trouble
          double_trouble.double_trouble!
          double_trouble.double_trouble?
          double_trouble._double_trouble
          instance.uses_class_config
          instance.uses_class_config!
          instance.uses_class_config?
          instance._uses_class_config
          instance.double_trouble
          instance.double_trouble!
          instance.double_trouble?
          instance._double_trouble

          expect(double_trouble.instance_variable_get(c_pointer)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(c_pointer_bang)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(c_pointer_q)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(c_pointer_u)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(k_pointer)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(k_pointer_bang)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(k_pointer_q)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(k_pointer_u)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(ic_pointer)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(ic_pointer_bang)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(ic_pointer_q)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(ic_pointer_u)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(i_pointer)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(i_pointer_bang)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(i_pointer_q)).to be_a(described_class) # now initialized
          expect(double_trouble.instance_variable_get(i_pointer_u)).to be_a(described_class) # now initialized
        end

        it 'keeps separate configs' do
          c_pointer = described_class.config_pointer('kl', :uses_class_config)
          c_pointer_bang = described_class.config_pointer('kl', :uses_class_config!)
          c_pointer_q = described_class.config_pointer('kl', :uses_class_config?)
          c_pointer_u = described_class.config_pointer('kl', :_uses_class_config)
          c_pointers = [c_pointer, c_pointer_bang, c_pointer_q, c_pointer_u]
          k_pointer = described_class.config_pointer('kl', :double_trouble)
          k_pointer_bang = described_class.config_pointer('kl', :double_trouble!)
          k_pointer_q = described_class.config_pointer('kl', :double_trouble?)
          k_pointer_u = described_class.config_pointer('kl', :_double_trouble)
          k_pointers = [k_pointer, k_pointer_bang, k_pointer_q, k_pointer_u]
          ic_pointer = described_class.config_pointer('ilm', :uses_class_config)
          ic_pointer_bang = described_class.config_pointer('ilm', :uses_class_config!)
          ic_pointer_q = described_class.config_pointer('ilm', :uses_class_config?)
          ic_pointer_u = described_class.config_pointer('ilm', :_uses_class_config)
          ic_pointers = [ic_pointer, ic_pointer_bang, ic_pointer_q, ic_pointer_u]
          i_pointer = described_class.config_pointer('ilm', :double_trouble)
          i_pointer_bang = described_class.config_pointer('ilm', :double_trouble!)
          i_pointer_q = described_class.config_pointer('ilm', :double_trouble?)
          i_pointer_u = described_class.config_pointer('ilm', :_double_trouble)
          i_pointers = [i_pointer, i_pointer_bang, i_pointer_q, i_pointer_u]

          double_trouble.uses_class_config
          double_trouble.uses_class_config!
          double_trouble.uses_class_config?
          double_trouble._uses_class_config
          double_trouble.double_trouble
          double_trouble.double_trouble!
          double_trouble.double_trouble?
          double_trouble._double_trouble
          instance.uses_class_config
          instance.uses_class_config!
          instance.uses_class_config?
          instance._uses_class_config
          instance.double_trouble
          instance.double_trouble!
          instance.double_trouble?
          instance._double_trouble

          # add_invocation_id gets overridden in double_trouble's configs
          c_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).add_invocation_id).to eq(false)
          end
          k_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).add_invocation_id).to eq(false)
          end
          ic_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).add_invocation_id).to eq(false)
          end
          i_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).add_invocation_id).to eq(true)
          end
          # debug_instance_benchmarks gets overridden in double_trouble's configs
          c_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).instance_benchmarks).to eq(false)
          end
          k_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).instance_benchmarks).to eq(true)
          end
          ic_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).instance_benchmarks).to eq(false)
          end
          i_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).instance_benchmarks).to eq(true)
          end
          # mark_scope_exit defaults to false, and is never overridden in double_trouble's configs
          c_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).mark_scope_exit).to eq(false)
          end
          k_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).mark_scope_exit).to eq(false)
          end
          ic_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).mark_scope_exit).to eq(false)
          end
          i_pointers.each do |pointer|
            expect(double_trouble.instance_variable_get(pointer).mark_scope_exit).to eq(false)
          end
        end
      end

      context 'instance logging' do
        it 'keeps separate class-level configs' do
          expect(instance_logged_klass_explicit.debug_instance_benchmarks).to eq(true)
          expect(instance_logged_klass_explicit.debug_add_invocation_id).to eq(true)
          expect(instance_logged_klass_dynamic.debug_instance_benchmarks).to eq(false)
          expect(instance_logged_klass_dynamic.debug_add_invocation_id).to eq(false)
        end

        it 'uses separate configs' do
          output = capture('stdout') do
            instance_logged_klass_explicit.new.i
            instance_logged_klass_explicit.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            instance_logged_klass_explicit.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                             e: { c: :d, e: :f })
            instance_logged_klass_dynamic.new.i_with_ssplat('z', 1, true, ['y', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/#i\(\) ~\d+@.+~/)
          expect(output).not_to match(/#i completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)/)
          expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)/)
          expect(output).to match(/#i_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\)/)
          expect(output).not_to match(/#i_with_dsplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          expect(output).to match(/#i_with_ssplat\("z", 1, true, \["y", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/)
          expect(output).not_to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
        end

        it 'has correct return value' do
          expect(instance_logged_klass_explicit.new.i).to eq(40)
          expect(instance_logged_klass_explicit.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                  { c: :d, e: :f })).to eq(50)
          expect(instance_logged_klass_explicit.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                                  e: { c: :d, e: :f })).to eq(60)
          expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                 { c: :d, e: :f })).to eq(50)
        end
      end

      context 'class logging' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          singleton_logged_klass.debug_class_benchmarks = true
          singleton_logged_klass.debug_add_invocation_id = false
          complete_logged_klass.debug_class_benchmarks = false
          complete_logged_klass.debug_add_invocation_id = true
        end

        it 'keeps separate configs' do
          expect(singleton_logged_klass.debug_class_benchmarks).to eq(true)
          expect(singleton_logged_klass.debug_add_invocation_id).to eq(false)
          expect(complete_logged_klass.debug_class_benchmarks).to eq(false)
          expect(complete_logged_klass.debug_add_invocation_id).to eq(true)
        end

        it 'uses separate configs' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            complete_logged_klass.k_with_ssplat('x', 1, true, ['y', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) debug: \{\}/)
          expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)/)
          expect(output).to match(/\.k_with_ssplat\("x", 1, true, \["y", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~ debug: \{\}\Z/)
          expect(output).not_to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          expect(complete_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
        end
      end
    end

    context 'last_hash_to_s_proc' do
      context 'class level config' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
        end

        it 'logs' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                      e: { c: :d, e: :f })).to eq(30)
        end
      end

      context 'instance level config' do
        before do
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
          instance_logged_klass_dynamic.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
        end

        it 'logs' do
          output = capture('stdout') do
            instance_logged_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                            e: { c: :d, e: :f })
          end
          expect(output).to match(/#i_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/)
        end

        it 'has correct return value' do
          expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                                 e: { c: :d, e: :f })).to eq(60)
        end
      end
    end

    context 'multiple_last_hashes' do
      context 'class level config' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
          singleton_logged_klass.debug_multiple_last_hashes = true
        end

        it 'logs' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f }, a: 'a', b: 1,
                                                                                                  c: true, d: ['b', 2, false], e: { c: :d, e: :f })
            singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], \[:c, :e\], \[:a, :b, :c, :d, :e\]\) ~/)
          expect(output).to match(/\.k_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f }, a: 'a', b: 1,
                                                                                                       c: true, d: ['b', 2, false], e: { c: :d, e: :f })).to eq(20)
          expect(singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                      e: { c: :d, e: :f })).to eq(30)
        end
      end

      context 'instance level config' do
        before do
          allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
          instance_logged_klass_dynamic.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
          instance_logged_klass_dynamic.debug_multiple_last_hashes = true
        end

        it 'logs' do
          output = capture('stdout') do
            instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f }, a: 'a',
                                                                                                             b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
            instance_logged_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                            e: { c: :d, e: :f })
          end
          expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], \[:c, :e\], \[:a, :b, :c, :d, :e\]\) ~/)
          expect(output).to match(/#i_with_dsplat\(\[:a, :b, :c, :d, :e\]\) ~/)
        end

        it 'has correct return value' do
          expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f },
                                                                 a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })).to eq(50)
          expect(instance_logged_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                                 e: { c: :d, e: :f })).to eq(60)
        end
      end
    end

    context 'last_hash_max_length' do
      context 'when last_hash_to_s_proc is set' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
          singleton_logged_klass.debug_last_hash_max_length = 3
        end

        it 'logs ellipsis' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_dsplat\(\[:a, ✂️ …\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                      e: { c: :d, e: :f })).to eq(30)
        end
      end

      context 'when last_hash_to_s_proc is not set' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = nil
          singleton_logged_klass.debug_last_hash_max_length = 3
        end

        it 'logs full message' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_dsplat\(\*\*{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false],
                                                      e: { c: :d, e: :f })).to eq(30)
        end
      end
    end

    context 'args_max_length' do
      context 'when last_hash_to_s_proc is set' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = ->(hash) { hash.keys.to_s }
          singleton_logged_klass.debug_args_max_length = 20
        end

        it 'logs full messages when under max' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \[:c, :e\]\) ~/)
        end

        it 'logs ellipsis' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2 ✂️ …, \[:c, :e\]\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
        end
      end

      context 'when last_hash_to_s_proc is not set' do
        before do
          skip_for(engine: 'ruby', versions: ['2.0.0'],
                   reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
          allow(singleton_logged_klass).to receive(:debug_log) { logger }
          singleton_logged_klass.debug_last_hash_to_s_proc = nil
          singleton_logged_klass.debug_args_max_length = 20
        end

        it 'logs full messages when under max' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, { c: :d })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, {:c=>:d}\) ~/)
        end

        it 'logs ellipsis' do
          output = capture('stdout') do
            singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
          end
          expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2 ✂️ …\) ~/)
        end

        it 'has correct return value' do
          expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
        end
      end
    end

    context 'instance_benchamrks' do
      before do
        allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
        instance_logged_klass_dynamic.debug_instance_benchmarks = true
      end

      it 'logs benchmark' do
        output = capture('stdout') do
          instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
        end
        expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/)
        expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~/)
      end

      it 'has correct return value' do
        expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                               { c: :d, e: :f })).to eq(50)
      end
    end

    context 'class_benchamrks' do
      before do
        skip_for(engine: 'ruby', versions: ['2.0.0'],
                 reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
        allow(singleton_logged_klass).to receive(:debug_log) { logger }
        singleton_logged_klass.debug_class_benchmarks = true
      end

      it 'logs benchmark' do
        output = capture('stdout') do
          singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
        end
        expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~/)
        expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~/)
      end

      it 'has correct return value' do
        expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
      end
    end

    context 'add_invocation_id' do
      context 'singleton' do
        context 'add_invocation_id is true' do
          before do
            skip_for(engine: 'ruby', versions: ['2.0.0'],
                     reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = true
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/)
            expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          end

          it 'has correct return value' do
            expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          end
        end

        context 'add_invocation_id is false' do
          before do
            skip_for(engine: 'ruby', versions: ['2.0.0'],
                     reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = false
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)/)
            expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)\Z/)
          end

          it 'has correct return value' do
            expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          end
        end

        context 'add_invocation_id is proc' do
          before do
            skip_for(engine: 'ruby', versions: ['2.0.0'],
                     reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
            allow(singleton_logged_klass).to receive(:debug_log) { logger }
            singleton_logged_klass.debug_class_benchmarks = true
            singleton_logged_klass.debug_add_invocation_id = ->(colorized_string) { colorized_string.red }
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/\.k_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\).*0;31;49m ~\d+@.+~.*0m/)
            expect(output).to match(/\.k_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\).*0;31;49m ~\d+@.+~.*0m\Z/)
          end

          it 'has correct return value' do
            expect(singleton_logged_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
          end
        end
      end

      context 'instance' do
        context 'add_invocation_id is true' do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = true
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\) ~\d+@.+~/)
            expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\) ~\d+@.+~/)
          end

          it 'has correct return value' do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                   { c: :d, e: :f })).to eq(50)
          end
        end

        context 'add_invocation_id is false' do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = false
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\)/)
            expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\)\Z/)
          end

          it 'has correct return value' do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                   { c: :d, e: :f })).to eq(50)
          end
        end

        context 'add_invocation_id is proc' do
          before do
            allow(instance_logged_klass_dynamic).to receive(:debug_log) { logger }
            instance_logged_klass_dynamic.debug_instance_benchmarks = true
            instance_logged_klass_dynamic.debug_add_invocation_id = ->(colorized_string) { colorized_string.red }
          end

          it 'logs benchmark' do
            output = capture('stdout') do
              instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
            end
            expect(output).to match(/#i_with_ssplat\("a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\).*0;31;49m ~\d+@.+~.*0m/)
            expect(output).to match(/#i_with_ssplat completed in \d+\.?\d*s \(\d+\.?\d*s CPU\).*0;31;49m ~\d+@.+~.*0m\Z/)
          end

          it 'has correct return value' do
            expect(instance_logged_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false],
                                                                   { c: :d, e: :f })).to eq(50)
          end
        end
      end
    end
  end
end
