# xail - tail for winners

xail is a super lightweight Ruby DSL for building simple stream/log analysis
tools.

A simple log viewer: `logview.xail.rb`:


    #!/usr/bin/env xail
    group('fatal') {
        contains 'fatal'
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

You can then run it directly:

    $ ./logview.xail.rb

And it will accept input on stdin or a filename on the command line.

You can directly specify:

## Filters

There are filters and compound filters. A filter takes a line from a stream
and performs some action, potentially altering the stream, or terminating the flow.
Compound filters take a stream and also a set of subfilters. These generally implement
flow control.

Stdout is the ultimate consumer of the strings, unless they've been redirected using `rest`.

### Compound Filters
* `cascade` -- stream the result of first subfilter that streams, a cascade filter is the container for your xail script
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
* `rest` -- a special compound filter that is applied to any unmatched streams

### Custom Filters

You can easily develop your own filters. Either as an anonymous block:

    filter do |stream|
      if stream.includes? 'awesome'
        nil # stop the stream
      else
        stream # keep it going
      end
    end

Or, if you need to preserve state, as a filter within the xail file:

    class LineNumbersFilter < AbstractFilter
        def initialize
          @lineno = 0
        end

        def streamLine(line)
          @lineno += 1
          return "%5d %s" % [@lineno, line]
        end
    end

    linenumbers
    group('fatal') {
        contains 'fatal'
        red
    }


### Hide unfiltered lines
By default xail will print any unfiltered lines as this is a more typical case.
You can hide unfiltered lines using a rest block. For example, to only show
exceptions:

    group('error') {
      contains 'exception'
      red
    }

    stop

### Fine-grained stream control
You can preform finer grained stream control using the `OR`, `AND`, and `NOT`
combinators.