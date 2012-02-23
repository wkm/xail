require 'rspec'

describe BellFitler do
  it "prepends a bell to the stream" do
    f = BellFilter.new
    f.streamLine("hi").should eq("\ahi")
end

