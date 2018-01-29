require 'spec_helper'

RSpec.describe Asynchronous::Enumerable do
  subject(:patched_enumerable) { enumerable.dup.tap { |a| a.extend(described_class) } }
  let(:enumerable) { [1, 2, 3, 4, 5] }

  describe '#concurrently' do
    subject(:concurrently_enum) { patched_enumerable.concurrently }

    it { expect(concurrently_enum.respond_to?(:each)).to be true }
    it { expect(concurrently_enum.each).to be concurrently_enum }

    describe '.map' do
      subject(:mapped_values) { concurrently_enum.map { |x| x + 1 } }
      let(:enumerable) { [5, 6, 7] }

      it { is_expected.to match_array [6, 7, 8] }
    end

    describe '.to_a' do
      subject(:to_a_value) { concurrently_enum.to_a }
      let(:enumerable) { [1, 2, 3] }

      it { is_expected.to match_array enumerable }
    end

    describe '.to_h' do
      subject(:to_h_value) { concurrently_enum.to_h }
      let(:enumerable) { { hello: 'world' } }

      it { is_expected.to match enumerable }
    end

    describe '.any?' do
      subject(:to_h_value) { concurrently_enum.any?(&any_block) }

      context 'when any block result is passable by at least one value' do
        let(:any_block) { proc { |n| n > 4 } }

        it { is_expected.to be true }
      end

      context 'when any block result is not passed by any value' do
        let(:any_block) { proc { |n| n > 5 } }

        it { is_expected.to be false }
      end
    end

    describe '.all?' do
      subject(:to_h_value) { concurrently_enum.all?(&any_block) }

      context 'when any block result is passable by all values' do
        let(:any_block) { proc { |n| n > 0 } }

        it { is_expected.to be true }
      end

      context 'when any block result is not passed by one of the values' do
        let(:any_block) { proc { |n| n > 1 } }

        it { is_expected.to be false }
      end
    end
  end
end
