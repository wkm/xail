
require 'term/ansicolor'

module Xail

  class FilterRegistry
    # naively assume all filters are defined in this file, or at least loaded
    # before this executes
    def self.find_filters
      filters = {}

      ObjectSpace.each_object(Class) do |cls|
        if cls.ancestors.include?(AbstractFilter) and
            not cls.to_s =~ /^.*Abstract.*$/
        then
          filters[cls]
        end
      end

      filters
    end

    def self.get_filter(name)
      @@filters ||= FilterRegistry.find_filters

      def find_filter(name)

      end

      # if we couldn't find the filter, rebuild the list and try
      # again
      @@filters = FilterRegistry.find_filters
    end
  end




  class AbstractFilter
    def filterName
      self.class.name.split('::').last.gsub(/filter/i, '')
    end

    def streamLine(line)
    end
  end



  #
  # Filter Composer
  #

  class AbstractCompoundFilter < AbstractFilter
    def initialize
      @filters = []
    end

    def <<(filter)
      @filters << filter
    end
  end


  # a cascade streams the next filter on rejection
  class FilterCascade < AbstractCompoundFilter
    def streamLine(input)
      @filters.each do |filter|
        line = filter.streamLine(input)
        if line != nil
          return line
        end
      end
    end
  end

  # a composition streams the next filter on success
  class FilterComposition < AbstractCompoundFilter
    def streamLine(input)
      @filters.inject(input) do |line,filter|
        if line != nil
          filter.streamLine(line)
        else
          nil
        end
      end
    end
  end

  # the And filter streams the original if all component filters stream
  class AndFilter < AbstractCompoundFilter
    def streamLine(line)
      @filters.each do |filter|
        if(!filter.streamLine(line))
          return nil
        end
      end

      line
    end
  end

  # the Or filter streams the original if any component filter streams
  class OrFilter < AbstractCompoundFilter
    def streamLine(line)
      @filters.each do |filter|
        if(filter.streamLine(line))
          return line
        end
      end
    end
  end

  # the Not filter streams the original if none of the component filters stream
  class NotFilter < AndFilter
    def streamLine(line)
      result = super.streamLine(line)

      if(result != nil)
        nil
      else
        line
      end
    end
  end


  # the Stop filter never succeeds
  class StopFilter < AbstractFilter
    def streamLine(line)
      nil
    end
  end




  #
  # Stream Mutators
  #

  class SampleFilter < AbstractFilter
    @count = 0
    @rate

    def initialize(params)
      @rate = params.to_i
    end

    def streamLine(line)
      if(@count % @rate == 0)
        line
      end
    end
  end




  #
  # Stream Decorators
  #

  class BellFilter < AbstractFilter
    def streamLine(line)
      return "\a"+line
    end
  end

  class AbstractColorFilter < AbstractFilter
    def initialize
      @colors = Term::ANSIColor
    end

    def streamLine(line)
      return @colors.send(filterName.gsub(/On/,"on_").downcase, line)
    end
  end


  # foregrounds
  class Black      < AbstractColorFilter; end
  class Red        < AbstractColorFilter; end
  class Green      < AbstractColorFilter; end
  class Yellow     < AbstractColorFilter; end
  class Blue       < AbstractColorFilter; end
  class Magenta    < AbstractColorFilter; end
  class Cyan       < AbstractColorFilter; end
  class White      < AbstractColorFilter; end

  # backgrounds
  class OnBlack    < AbstractColorFilter; end
  class OnRed      < AbstractColorFilter; end
  class OnGreen    < AbstractColorFilter; end
  class OnYellow   < AbstractColorFilter; end
  class OnBlue     < AbstractColorFilter; end
  class OnMagenta  < AbstractColorFilter; end
  class OnCyan     < AbstractColorFilter; end
  class OnWhite    < AbstractColorFilter; end

  # effects
  class Bold       < AbstractColorFilter; end
  class Blink      < AbstractColorFilter; end
  class Underscore < AbstractColorFilter; end
  class Negative   < AbstractColorFilter; end
  class Dark       < AbstractColorFilter; end
end