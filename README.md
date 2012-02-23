# xail - tail for winners

[not ready for public consumption]

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

You can directly specify:

## Filters

There are filters and compound filters. A filter takes a line from a stream
and performs some action, potentially altering the stream, or terminating the flow.
Compound filters take a stream and also a set of subfilters. These generally implement
flow control.

Stdout is the ultimate consumer of the strings, unless they've been filtered.

### Compound Filters
* `cascade` -- stream the result of first subfilter that streams
* `composition` -- applies each subfilter on the stream of the preceding subfilter, streaming the final result

* `and` -- streams the original if all subfilters stream
* `or` -- streams the original if any subfilter streams
* `not` -- streams the original if no subfilters stream

### Matching Filters
* `contains` -- streams the original if any of the parameters are included
* `replace` -- mutates the stream

### Alerting Filters
* `execute` executes a command, replacing `{}` with the line content
* `bell` rings a terminal bell (if possible)

### Styling Filters
* `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white` -- adjust foreground color
* `onblack`, `onred`, `ongreen`, `onyellow`, `onblue`, `onmagenta`, `oncyan`, `onwhite` -- adjust background color
* `bold`, `blink`, `underscore`, `negative`, `dark` -- apply effects to the text

### Special Filters
* `sample` -- samples the stream, only printing at the rate requested
* `stop` -- stops processing of this stream and continues with the next
* `count` -- [todo] computes the rate of the stream for display (need UI aspect)

### Custom Filters

You can easily develop your own filters. Either as an anonymous block:
