
require 'xail/filter'

module Xail
  module DSL
    def get_binding
      binding
    end

    def filter_scope(compound)
      filter_in_scope << compound
      @filter_stack << compound

      yield

      @filter_stack.pop
    end

    def filter(&block)
      filter_in_scope << Class.new(AbstractFilter) do
        def streamLine(line)
          block(line)
        end
      end
    end

    # TODO add support for explicitly listing sources
    #def stream(name, source = null)
    #  source ||= name
    #end

    def group(name, &filters)
      # TODO intergrate with UX
      filter_scope(FilterComposition.new) {
        filters.yield
      }
    end

    attr :has_final
    def rest(&filters)
      if @has_final
        raise "rest may only be specified once"
      end

      @has_final = true
      filter_scope(FilterComposition.new) {
        filters.yield
      }
    end

    def filter_in_scope
      @filter_stack ||= [FilterCascade.new]
      @filter_stack.last
    end

    def method_missing(name, *args, &block)
      abort "internal error #{name} #{args} #{block}" unless name
      filterClass = FilterRegistry::get_filter(name.downcase)
      filter_scope(filterClass.new(*args)) do
        block.yield if block
      end
      filter_in_scope << filter

    # short circuit the stream line stop exception so we can catch it
    # in xail main
    rescue StreamLineStop => stop
      raise stop

    rescue UnknownFilter => error
      abort error.to_s

    rescue => error
      abort "#{filter_in_scope} will not accept #{name} as subfilter: #{error}"
    end
  end
end
