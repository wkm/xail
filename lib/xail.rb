require 'yaml'
require 'trollop'
require 'pp'

require 'xail/version'
require 'xail/filter'
require 'xail/config'

module Xail
  @opts = Trollop::options do
    version "xail - #{VERSION} (c) 2012 w.k.macura - Released under BSD license"
    banner <<-EOS
A Ruby utility for performing basic stream processing, directly focused on increasing error visibility in logs
    EOS
  end


  def Xail.run(configuration)

    begin
      extend Xail::DSL

      eval(configuration)
      filter = filter_in_scope

      if !has_final
        filter << PassThroughFilter.new
      end
    end


    stream = $stdin
    stream.each() do |line|
      streamed = filter.streamLine(line)
      if streamed and streamed.size > 0
        printf streamed
      end
    end
  end

  config = IO.read(ARGV[0])
  Xail.run(config)
end
