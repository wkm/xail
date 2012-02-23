require 'yaml'
require 'trollop'
require 'pp'

require 'xail/version'
require 'xail/filter'

module Xail
  @opts = Trollop::options do
    version "xail - #{VERSION} (c) 2012 w.k.macura - Released under BSD license"
    banner <<-EOS
A Ruby utility for performing basic stream processing, directly focused on increasing error visibility in logs
    EOS
  end


  def Xail.run(configuration)
    stream = $stdin

    chain = FilterComposition.new
    chain << Blue.new
    chain << OnRed.new

    stream.each() do |line|
      printf chain.streamLine(line)
    end
  end

  Xail.run("")
end
