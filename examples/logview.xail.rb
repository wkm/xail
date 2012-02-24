#!/usr/bin/env xail
#
# a simple log error and warning highlighter
#

#!/usr/bin/env xail
group('fatal') {
  contains 'fatal'
  red
  underscore
  bell
}

group('error') {
  contains 'error', 'exception'
  bold
}

group('warning') {
  contains 'warn'
  yellow
}
