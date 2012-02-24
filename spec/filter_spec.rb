
require 'xail/filter'

include Xail

describe BellFilter do
  it "prepends a bell to the stream" do
    f = BellFilter.new
    f.streamLine("hi").should eq("\ahi")
  end
end

describe Yellow do
  it "should apply escape codes to the filter" do
    f = Yellow.new
    f.streamLine("hi").should eq("\e[33mhi\e[0m")
  end
end

describe PassThroughFilter do
  it "should passthrough streams" do
    f = PassThroughFilter.new
    f.streamLine("hi").should eq("hi")
  end
end

describe SinkFilter do
  it "should sink all streams" do
    f = SinkFilter.new
    f.streamLine("hi").should eq(nil)
  end
end

describe StopFilter do
  it "should stop all processing of this stream-line" do
    f = StopFilter.new
    lambda { f.streamLine("hi") }.should raise_error(StreamLineStop)
  end
end

describe ContainsFilter do
  it "should stream if it matches" do
    f = ContainsFilter.new("hi")
    f.streamLine("bye").should eq(nil)
    f.streamLine("hi there").should eq("hi there")
  end
end

describe ReplaceFilter do
  it "should replace on streams" do
    f = ReplaceFilter.new(/hi/ => 'bye', /there/ => 'potato')
    f.streamLine("hi there").should eq("bye potato")
  end
end

describe SampleFilter do
  it "should sample at the given rate" do
    f = SampleFilter.new(5)
    f.streamLine("a").should eq "a"
    f.streamLine("b").should eq ""
    f.streamLine("c").should eq ""
    f.streamLine("d").should eq ""
    f.streamLine("e").should eq ""
    f.streamLine("f").should eq "f"
  end
end

describe FilterCascade do
  it "should cascade through" do
    f = FilterCascade.new
    f << SinkFilter.new
    f << SinkFilter.new
    f << ContainsFilter.new("hi")
    f << SinkFilter.new

    f.streamLine("bye").should eq(nil)
    f.streamLine("hi").should eq("hi")
  end
end

describe FilterComposition do
  it "should compose through" do
    f = FilterComposition.new
    f << ReplaceFilter.new('a'=>'b')
    f << ContainsFilter.new('hi')

    f.streamLine('bye').should eq(nil)
    f.streamLine('hi there alice').should eq('hi there blice')
  end
end

describe OrFilter do
  it "should act like logical or" do
    f = OrFilter.new
    f << ContainsFilter.new('a')
    f << ContainsFilter.new('b')

    f.streamLine('a').should eq('a')
    f.streamLine('b').should eq('b')
    f.streamLine('c').should eq(nil)
  end
end

describe AndFilter do
  it "should act like logical and" do
    f = AndFilter.new
    f << ContainsFilter.new('a')
    f << ContainsFilter.new('b')

    f.streamLine('a').should eq(nil)
    f.streamLine('b').should eq(nil)
    f.streamLine('ab').should eq('ab')
  end
end

describe NotFilter do
  it "should act like logical not" do
    f = NotFilter.new
    f << ContainsFilter.new('a')

    f.streamLine('a').should eq(nil)
    f.streamLine('b').should eq('b')
  end

  it "should take multiple subfilters" do
    f = NotFilter.new
    f << ContainsFilter.new('a')
    f << ContainsFilter.new('b')

    f.streamLine('a').should eq(nil)
    f.streamLine('b').should eq(nil)
    f.streamLine('c').should eq('c')
  end
end