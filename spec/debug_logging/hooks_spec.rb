RSpec.describe DebugLogging::Hooks do
  context 'when .debug_time_box is used' do
    it 'does not let the method exceed a given time limit' do
      timeout_time = 0.5
      klass = Class.new do
        include DebugLogging::Hooks
        def meth
          sleep 1
        end
        debug_time_box(timeout_time, :meth)
      end
      start_time = Time.now
      begin
        klass.new.meth
      rescue StandardError
        end_time = Time.now
      end
      result = end_time - start_time
      expect(result.round(1)).to eq(timeout_time)
    end

    context 'without a block and the method call expires' do
      before do
        test_class = Class.new do
          include DebugLogging::Hooks
          def meth
            sleep 0.2
          end
          debug_time_box(0.1, :meth)
        end

        @result =
          begin
            test_class.new.meth
          rescue StandardError => e
            e
          end
      end

      it "throws #{DebugLogging::TimeoutError} error" do
        expect(@result).to(be_a(DebugLogging::TimeoutError))
      end
    end

    context 'with a block and the method call expires' do
      before do
        expected_result = 'expected-result'
        @expected_result = expected_result

        test_class = Class.new do
          include DebugLogging::Hooks

          attr_reader :args

          def meth
            sleep 0.2
          end

          debug_time_box(0.1, :meth) do |*args|
            @args = args
            expected_result
          end
        end

        @test_obj = test_class.new
        @result =
          begin
            @test_obj.meth
          rescue StandardError => e
            e
          end
      end

      it 'returns the result of the given block' do
        expect(@expected_result).to eq(@result)
      end

      it 'yields an array of argument errors' do
        args = @test_obj.args
        expect(args).to be_a(Array)
        expect(args[0]).to eq(DebugLogging::TimeoutError)
        expect(args[1]).to be_a(String)
        expect(args[2]).to be_a(Array)
      end
    end

    context 'with a block and the method does not expire' do
      before do
        test_class = Class.new do
          include DebugLogging::Hooks

          def self.expected_result
            'expected-result'
          end

          attr_reader :args

          def meth
            sleep 0.1
            self.class.expected_result
          end

          debug_time_box(0.2, :meth) do |*args|
            @args = args
            raise 'bad'
          end
        end

        @test_obj = test_class.new
        @result =
          begin
            @test_obj.meth
          rescue StandardError => e
            e
          end
      end

      it 'returns the result of the method' do
        expect(@result).to eq(@test_obj.class.expected_result)
      end
    end
  end

  context 'when .debug_rescue_on_fail is used' do
    context 'when no block is provided' do
      before do
        @result =
          begin
            Class.new do
              include DebugLogging::Hooks

              def meth; end

              debug_rescue_on_fail(:meth)
            end
          rescue DebugLogging::NoBlockGiven => e
            e
          end
      end

      it "raises #{DebugLogging::NoBlockGiven}" do
        expect(@result).to be_a(DebugLogging::NoBlockGiven)
      end
    end

    context 'when the method fails' do
      blk = ->(err = nil) { { test_value: 'test', error: err } }

      before do
        @test_class =
          Class.new do
            include DebugLogging::Hooks

            def meth
              raise StandardError, 'fart sound'
            end

            debug_rescue_on_fail(:meth, &blk)
          end
      end

      it 'returns the result of the block' do
        result = @test_class.new.meth
        expected = blk.call
        expect(result[:test_value]).to eq(expected[:test_value])
      end

      it 'yields an error object' do
        result = @test_class.new.meth
        expect(result[:error]).to be_a(StandardError)
      end
    end
  end

  context 'when .debug_before is used' do
    before do
      @test_class = Class.new do
        # require 'rspec/expectations'
        include DebugLogging::Hooks
        def meth(*_args, &_blk)
          nil
        end
      end
    end

    context 'without a block given' do
      it 'raises an error' do
        result =
          begin
            @test_class.instance_exec do
              debug_before(:meth)
            end
          rescue DebugLogging::NoBlockGiven => e
            e
          end
        expect(result).to be_a(DebugLogging::NoBlockGiven)
      end
    end

    context 'when given a block' do
      it 'yields the methods arguments' do
        test_data = { name: :meth,
                      args: [1, 2],
                      blk: -> { 'test' } }
        @test_class.instance_exec(self) do |slf|
          debug_before(test_data[:name]) do |name, *args|
            slf.expect(name).to slf.eq(test_data[:name])
            slf.expect(args).to slf.eq([*test_data[:args], test_data[:blk]])
          end
        end
        @test_class.new.meth(*test_data[:args], &test_data[:blk])
      end
    end

    it 'the block is called before the method' do
      value = nil
      @test_class.instance_exec(self) do |_slf|
        define_method(:meth) do
          value = 'in method'
        end

        debug_before(:meth) do
          value = 'in before'
        end
      end
      @test_class.new.meth
      expect(value).to eq('in method')
    end
  end

  context 'when .debug_after is used' do
    pending 'it should work'
  end
end
