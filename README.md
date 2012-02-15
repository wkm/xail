# xail - tail for winners

xail is basically `tail` with a few addons to make it more useful for log
viewing and the like. It's super lightweight.


## Categorizing

The main point of xail is to increase visibility of errors, through directly
highlighting, but also isolating error lines. The default configuration:

* `fatal` -- fatal conditions (bold red)
* `error`, `exception` -- error conditions (red)
* `warning`, `warn` -- warning conditions (yellow)

## Statistics

By default xail will give you the log velocity for the last second, five
seconds, and minute.
