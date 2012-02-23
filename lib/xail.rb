require 'yaml'
require 'trollop'
require 'pp'

require 'xail/version'
require 'xail/filter'

module Xail
  @opts = Trollop::options do
    version "xail - #{VERSION} (c) 2012 w.k.macura - Released under BSD license"
    banner <<-EOS
A Ruby utility for performing basic stream processing, directly focused on increasing
error visibility in logs
    EOS

    opt :config, 'the yaml configuration to use with xail'
    opt :stream, 'the initial stream', :type => :string, :default => "-"
  end


  def Xail.run(configuration)
    stream = configuration['stream']
    filters = configuration['filters']

    if stream.instance_of? String then
      stream = File.open(stream)
    end

    chain = FilterCascade.new
    chain << Blue.new

    stream.each() do |line|
      puts chain.stream(line)
    end
  end

  if @opts[:stream] == "-" then
    @opts[:stream] = $stdin
  end


  #yamlconfig = YAML.load_file(@opts['config'])
  #run(yamlconfig)
  run('stream' => @opts[:stream])
end
