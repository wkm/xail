#!/usr/bin/env xail
#
# a simple log error and warning highlighter
#

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
