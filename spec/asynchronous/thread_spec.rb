require 'spec_helper'

RSpec.describe Asynchronous::Thread do
  subject(:thread) { described_class.new(&block) }

  describe '#join' do
    subject(:joining) { thread.join }
    let(:block) { proc { sleep(1.5) } }

    it { is_expected.to be thread }
    it { expect { 3.times { thread.join } }.to_not raise_error }
    it { expect { Timeout.timeout(1) { joining } }.to raise_error(Timeout::Error) }
    it { expect { joining; Process.kill(0, thread.instance_variable_get(:@pid)) }.to raise_error(Errno::ESRCH) }

    context 'when exception raised in the thread' do
      let(:block) { proc { raise 'boom' } }

      it { expect { joining }.to raise_error 'boom' }
    end
  end

  describe '#value' do
    subject(:value) { thread.value }

    [
      true,
      false,

      42,
      -42,
      (2**30),
      (2**30) - 1,

      42.13,
      -42.13,
      (2**30) + 0.1,
      (2**30) + 0.1 - 1,

      [1, 2, 3],

      { :a => :b },

      'hello world!',
      :hello_world,
      :"hello world!",

      StandardError.new('Boom!')
    ].each do |expected_value|
      context "when the return value is a #{expected_value.class}" do
        let(:block) { proc { expected_value } }

        it { is_expected.to eq expected_value }
        it { is_expected.to be_a expected_value.class }
      end
    end

    context "when it's a custom class" do
      expected_value = ExampleCustomClassForValue.new('test')
      let(:block) { proc { expected_value } }

      get_instance_variables = lambda do |object|
        object.instance_variables.map { |iv| object.instance_variable_get(iv) }.sort
      end

      it { is_expected.to be_a expected_value.class }
      it { expect(get_instance_variables.call(value)).to eq get_instance_variables.call(expected_value) }
    end

    context "when it's a huge string" do
      long_string = 'X' * 1024 * 100
      let(:block) { proc { long_string } }
      it { is_expected.to eq long_string }
    end

    context 'when an exception raised in the async process' do
      let(:block) { proc { raise 'boom!' } }
      it { expect { value }.to raise_error 'boom!' }
    end
  end

  describe '#kill' do
    subject(:killing) { thread.kill }

    context 'given the thread running in the background' do
      let(:block) { proc { sleep(10) } }

      it { expect { killing }.to_not raise_error }
    end

    context 'given thread not running in the background anymore' do
      let(:block) { proc {} }

      it { expect { sleep(1); killing }.to_not raise_error }
    end

    context 'given thread already killed' do
      let(:block) { proc {} }

      it { expect { sleep(1); 3.times { thread.kill } }.to_not raise_error }
    end
  end

  describe '#status' do
    subject(:status) { thread.status }

    context 'when thread is alive' do
      let(:block) { proc { sleep(5) } }

      it { is_expected.to eq 'run' }
    end

    context 'when thread is completed' do
      let(:block) { proc {} }
      before { thread.join }
      it { is_expected.to eq false }
    end

    context 'when thread is killed' do
      let(:block) { proc { sleep(10) } }
      before { thread.kill }
      it { is_expected.to be false }
    end
  end

  describe 'no zombies' do
    subject(:pid) { `ruby -r "#{BOOTSTRAP_FILE_PATH}" -e "pid = async { sleep(15) }.instance_variable_get(:@pid); puts pid "`.to_i }

    it { expect { pid; sleep(2); Process.kill(0, pid) }.to raise_error Errno::ESRCH }
  end
end

# http://ruby-doc.org/core-2.2.0/Thread.html
# join
# key?
# keys
# kill
# pending_interrupt?
# priority
# priority=
# raise
# run
# safe_level
# set_trace_func
# status
# stop?
# terminate
# thread_variable?
# thread_variable_get
# thread_variable_set
# thread_variables
# value
# wakeup
