require 'xail/config'

include Xail

describe Config do
  it "should support a trivial filter" do
    filter = build_from_config <<-CONF
      group('main') {
        contains 'cat'
        red
      }
    CONF

    filter.streamLine('dog').should eq('dog')
    filter.streamLine('cat').should eq("\e[31mcat\e[0m")
  end
end