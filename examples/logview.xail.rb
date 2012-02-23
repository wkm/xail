#!/bin/env xail
group('fatal') {
  match 'fatal'
  bell
}

group('error') {
  match 'error', 'exception'
  red
  bold
}

group('warning') {
  match 'warn'
  yello
}
