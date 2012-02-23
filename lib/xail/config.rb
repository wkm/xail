
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

    def stream(name, source = null)
      source ||= name
    end

    def group(name, &filters)
      # TODO intergrate with UX
      filter_scope(FilterComposition.new) {
        filters.yield
      }
    end

    def has_final
      @has_final
    end

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
      filterClass = FilterRegistry::get_filter(name.downcase)
      filter = filterClass.new(*args)
      filter_in_scope << filter

    rescue UnknownFilter => error
      abort error.to_s

    rescue => error
      abort "#{filter_in_scope} will not accept #{name} as subfilter: #{error}"
    end
  end
end