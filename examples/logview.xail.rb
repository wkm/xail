#!/usr/bin/env xail
#
# a simple log error and warning highlighter
#

class ExecuteFilter < AbstractFilter
  def initialize(command)
    @command = command
  end

  def streamLine(line)
    @count ||= 0
    @count +=1
    puts "EXECUTING #{@count}: #{@command} #{line}"
    return line
  end
end


group("") {
  sample 500
}

rest {
  stop
}