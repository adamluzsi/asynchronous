require_relative 'test_helper'
describe Asynchronous do

  it 'should do concurrency pattern calculations' do

    calculation = async :concurrency do

      sleep 2
      4 * 2

    end
    calculation += 1

    calculation.must_be :==, 9

    calculation = async { sleep 3; 4 * 3 }
    calculation += 1

    calculation.must_be :==, 13

  end

  it 'should do parallel actions' do

    calculation = async :parallelism do
      sleep 4
      4 * 5
    end

    calculation += 1

    calculation.must_be :==, 21


    calc1 = async :os do

      sleep 4
      # some big database processing brutal memory eater stuff
      [4*5,"hy"]

    end

    calc2 = async {
      [5+1,"sup!"]
    }

    (calc1 == calc2).must_be :==, false
    (calc1+calc2).must_be :==, [4*5,"hy"] + [5+1,"sup!"]

  end

  it 'should create a ruby worker'


end
