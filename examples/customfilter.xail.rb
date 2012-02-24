#!/usr/bin/env xail

class ExecuteFilter < AbstractFilter
  def initialize(command)
    @command = command
  end

  def streamLine(line)
    puts "WOULD EXECUTE: #{@command} #{line}"
    return line
  end
end

group('exec') {
  contains 'exec'
  execute 'echo'
  stop
}

rest {
  stop
}