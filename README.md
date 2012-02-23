# xail - tail for winners

xail is a super lightweight Ruby DSL for building simple stream/log analysis
tools.

A simple log viewer: `logview.xail.rb`:


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

You can then run it directly:

    $ ./logview.xail.rb

And it will accept input on stdin or a filename on the command line.


