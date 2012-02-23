
require 'xail/filter'

module Xail
  module DSL
    @filter_stack = []
    @filter_stack << FilterCascade.new

    def stream(name, source = null)
      source ||= name
    end

    def group(name, &filters)

    end

    def rest(&filters)

    end

    def filter_in_scope
      @fitler_stack.last
    end

    def send(name, *args)
      filterClass = FilterRegistry::get_filter(name)
      filter = Object::const_get(filterClass).new(*args)
      filter_in_scope << filter
    rescue UnknownFilter => error
      puts error
      exit -1
    rescue => error
      puts "#{filter_in_scope} will not subfilter with #{name}"
      exit -1
    end
  end
end