describe :array_clone, shared: true do
  it "returns an Array or a subclass instance" do
    [].send(@method).should be_an_instance_of(Array)
    ArraySpecs::MyArray[1, 2].send(@method).should be_an_instance_of(ArraySpecs::MyArray)
  end

  it "produces a shallow copy where the references are directly copied" do
    a = [mock('1'), mock('2')]
    b = a.send @method
    b.first.should equal a.first
    b.last.should equal a.last
  end

  #FIXME add back once __id__ has been properly implemented
  xit "creates a new array containing all elements or the original" do
    a = [1, 2, 3, 4]
    b = a.send @method
    b.should == a
    b.__id__.should_not == a.__id__
  end

  ruby_version_is ''...'2.7' do
    it "copies taint status from the original" do
      a = [1, 2, 3, 4]
      b = [1, 2, 3, 4]
      a.taint
      aa = a.send @method
      bb = b.send @method

      aa.should.tainted?
      bb.should_not.tainted?
    end

    it "copies untrusted status from the original" do
      a = [1, 2, 3, 4]
      b = [1, 2, 3, 4]
      a.untrust
      aa = a.send @method
      bb = b.send @method

      aa.should.untrusted?
      bb.should_not.untrusted?
    end
  end
end
