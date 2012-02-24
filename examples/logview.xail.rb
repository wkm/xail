#!/usr/bin/env xail
#
# a simple log error and warning highlighter
#

class ExecuteFilter < AbstractFilter
  def initialize(command)
    @command = command
  end

  def streamLine(line)
    puts "EXECUTING #{@command} #{line}"
    return line
  end
end


group('fatal') {
  contains 'fatal'
  red
  onblue
  bell
}

group('error') {
  contains 'error', 'exception'
  red
  bold
}

group('warning') {
  contains 'warn'
  yellow
}
