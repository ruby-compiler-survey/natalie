require_relative '../spec_helper'

describe 'Kernel' do
  describe '#enum_for' do
    it 'returns a new Enumerator created by calling the given method' do
      a = [1, 2, 3]
      enum = a.enum_for(:each)
      enum.should be_an_instance_of(Enumerator)
      enum.to_a.should == [1, 2, 3]
    end
  end

  describe '#sleep' do
    it 'sleeps the number of seconds' do
      # TODO: add a way to measure time
      sleep 1
      sleep 0.1
    end

    it 'raises an error when given a non-numeric object' do
      -> { sleep :foo }.should raise_error(TypeError, "can't convert Symbol into time interval")
    end
  end
end
