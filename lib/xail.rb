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
    filter = Xail.build_from_config(configuration)

    stream = $stdin
    stream.each() do |line|
      begin
        streamed = filter.streamLine(line)
        if streamed and streamed.size > 0
          print streamed
        end

      rescue StreamLineStop
      end
    end
  end

  config = IO.read(ARGV[0])
  Xail.run(config)

rescue SignalException
  exit
end
