# frozen_string_literal: true

require 'spec_helper'
DebugLogging.configuration.active_support_notifications = true

RSpec.describe DebugLogging::InstanceNotifier do
  include_context 'with example classes'

  before do
    @events = []
    @subscriber = ActiveSupport::Notifications.subscribe(/log/) do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  context 'an instance notified klass explicit' do
    it 'notifies' do
      output = capture('stdout') do
        instance_notified_klass_explicit.new.i
        instance_notified_klass_explicit.new.i_with_ssplat
        instance_notified_klass_explicit.new.i_with_dsplat
        instance_notified_klass_explicit.new(action: 'Update', id: 1, msg: { greeting: 'hi' }).i_with_instance_vars
        instance_notified_klass_explicit.new(action: 'Create', id: 2, msg: { greeting: 'bye' }).i_with_instance_vars
      end
      expect(output).to match('i.log')
      expect(output).to match('payload={:debug_args=>\[\]}')
      expect(output).to match('i_with_ssplat.log')
      expect(output).to match('payload={:debug_args=>\[\], :id=>1, :first_name=>"Joe", :last_name=>"Schmoe"}')
      expect(output).to match('i_with_dsplat.log')
      expect(output).to match('payload={:debug_args=>\[\], :salutation=>"Mr.", :suffix=>"Jr."}')
      expect(output).to match('i_with_instance_vars.log')
      expect(output).to match('payload={:debug_args=>\[\], :action=>"Update", :id=>1, :msg=>{:greeting=>"hi"}}')
      expect(output).to match('i_with_instance_vars.log')
      expect(output).to match('payload={:debug_args=>\[\], :action=>"Create", :id=>2, :msg=>{:greeting=>"bye"}}')
      expect(@events).to contain_exactly(
        have_attributes(name: 'i.log', payload: { debug_args: [] }),
        have_attributes(name: 'i_with_ssplat.log', payload: { debug_args: [], id: 1, first_name: 'Joe', last_name: 'Schmoe' }),
        have_attributes(name: 'i_with_dsplat.log', payload: { debug_args: [], salutation: 'Mr.', suffix: 'Jr.' }),
        have_attributes(name: 'i_with_instance_vars.log', payload: { debug_args: [], action: 'Update', id: 1, msg: { greeting: 'hi' } }),
        have_attributes(name: 'i_with_instance_vars.log', payload: { debug_args: [], action: 'Create', id: 2, msg: { greeting: 'bye' } })
      )
    end

    it 'has correct return value' do
      expect(instance_notified_klass_explicit.new.i).to eq(40)
      expect(instance_notified_klass_explicit.new.i_with_ssplat).to eq(50)
      expect(instance_notified_klass_explicit.new.i_with_dsplat).to eq(60)
      expect(instance_notified_klass_explicit.new(action: 'Update', id: 1, msg: { greeting: 'hi' }).i_with_instance_vars).to eq(70)
    end
  end

  context 'an instance notified klass dynamic' do
    context 'instance method without args' do
      it 'notifies' do
        output = capture('stdout') do
          instance_notified_klass_dynamic.new.i
        end
        expect(output).to match('i.log')
        expect(output).to match('payload={:debug_args=>\[\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'i.log', payload: { debug_args: [] })
        )
      end

      it 'has correct return value' do
        expect(instance_notified_klass_dynamic.new.i).to eq(40)
      end
    end

    context 'instance method with single splat args' do
      it 'notifies' do
        output = capture('stdout') do
          instance_notified_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
        end
        expect(output).to match('i_with_ssplat.log')
        expect(output).to match('payload={:debug_args=>\["a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'i_with_ssplat.log', payload: { debug_args: ['a', 1, true, ['b', 2, false], { c: :d, e: :f }] })
        )
      end

      it 'has correct return value' do
        expect(instance_notified_klass_dynamic.new.i_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(50)
      end
    end

    context 'instance method with double splat args' do
      it 'notifies' do
        output = capture('stdout') do
          instance_notified_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
        end
        expect(output).to match('i_with_dsplat.log')
        expect(output).to match('payload={:debug_args=>\[{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'i_with_dsplat.log', payload: { debug_args: [{ a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f } }] })
        )
      end

      it 'has correct return value' do
        expect(instance_notified_klass_dynamic.new.i_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })).to eq(60)
      end
    end

    context 'instance method not logged' do
      it 'does not notify' do
        output = capture('stdout') do
          instance_notified_klass_dynamic.new.i_without_log
        end
        expect(output).to_not receive(:debug_log)
        expect(@events).to be_empty
      end

      it 'has correct return value' do
        expect(instance_notified_klass_dynamic.new.i_without_log).to eq(0)
      end
    end
  end

  context 'a singleton logged klass' do
    before do
      skip_for(engine: 'ruby', versions: ['2.0.0'], reason: 'method definitions return symbol name of method starting with Ruby 2.1, so class method logging not possible')
    end

    context 'class method without args' do
      it 'notifies' do
        output = capture('stdout') do
          singleton_notified_klass.k
        end
        expect(output).to match('k.log')
        expect(output).to match('payload={:debug_args=>\[\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'k.log', payload: { debug_args: [] })
        )
      end

      it 'has correct return value' do
        expect(singleton_notified_klass.k).to eq(10)
      end
    end

    context 'class method with single splat args' do
      it 'notifies' do
        output = capture('stdout') do
          singleton_notified_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })
        end
        expect(output).to match('k_with_ssplat.log')
        expect(output).to match('payload={:debug_args=>\["a", 1, true, \["b", 2, false\], {:c=>:d, :e=>:f}\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'k_with_ssplat.log', payload: { debug_args: ['a', 1, true, ['b', 2, false], { c: :d, e: :f }] })
        )
      end

      it 'has correct return value' do
        expect(singleton_notified_klass.k_with_ssplat('a', 1, true, ['b', 2, false], { c: :d, e: :f })).to eq(20)
      end
    end

    context 'class method with double splat args' do
      it 'notifies' do
        output = capture('stdout') do
          singleton_notified_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })
        end
        expect(output).to match('k_with_dsplat.log')
        expect(output).to match('payload={:debug_args=>\[{:a=>"a", :b=>1, :c=>true, :d=>\["b", 2, false\], :e=>{:c=>:d, :e=>:f}}\]}')
        expect(@events).to contain_exactly(
          have_attributes(name: 'k_with_dsplat.log', payload: { debug_args: [{ a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f } }] })
        )
      end

      it 'has correct return value' do
        expect(singleton_notified_klass.k_with_dsplat(a: 'a', b: 1, c: true, d: ['b', 2, false], e: { c: :d, e: :f })).to eq(30)
      end
    end

    context 'class method not logged' do
      it 'does not notify' do
        output = capture('stdout') do
          singleton_notified_klass.k_without_log
        end
        expect(output).to eq('')
        expect(@events).to be_empty
      end

      it 'has correct return value' do
        expect(singleton_notified_klass.k_without_log).to eq(0)
      end
    end
  end
end
