require 'spec_helper'

RSpec.describe Asynchronous::Pool do
  subject(:pool) { described_class.new(pool_size) }

  describe '#async' do
    subject(:thr) { async_call_number.times.map { pool.async(&block) } }

    context 'when the pool size is equal to the requested async calls number' do
      let(:block) { proc { sleep(0.5) } }
      let(:async_call_number) { 3 }
      let(:pool_size) { 3 }

      it { is_expected.to include be_a Asynchronous::Thread }
      it { is_expect.to finish_within(1) }
    end

    context 'when the pool size is bigger to the requested async calls number' do
      let(:block) { proc { sleep(0.5) } }
      let(:async_call_number) { 2 }
      let(:pool_size) { 3 }

      it { is_expected.to include be_a Asynchronous::Thread }
      it { is_expect.to finish_within(1) }
    end

    context 'when the pool size is smaller to the requested async calls number' do
      let(:block) { proc { sleep(0.5) } }
      let(:async_call_number) { 4 }
      let(:pool_size) { 2 }

      it { is_expected.to include be_a Asynchronous::Thread }
      it { is_expect.to finish_within(0.6) }

      it 'will blocked until the async process finish in the pool before it could take new async requests' do
        is_expect.to_not finish_within(0.4)
      end
    end
  end
end
