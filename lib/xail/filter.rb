
require 'term/ansicolor'

module Xail

  class UnknownFilter < Exception
    def initialize(filter)
      super("Unknown filter ``#{filter}''. Known: #{FilterRegistry.filters.keys.sort}")
    end
  end

  class FilterRegistry
    def self.filters
      @@filters ||= FilterRegistry.find_filters
    end


    # naively assume all filters are defined in this file, or at least loaded
    # before this executes
    def self.find_filters
      filters = Hash.new
      ObjectSpace.each_object(Class).select { |classObject|
        classObject < AbstractFilter and
        not classObject.name.downcase.include? "abstract"
      }.map { |filterclass|
        filtername = filterclass.name.split('::').last.gsub(/filter/i, '')
        filters[filtername.downcase] = filterclass
      }

      filters
    end

    def self.get_filter(key)
      name = key.to_s

      @@filters ||= FilterRegistry.filters

      if @@filters.has_key? name
        return @@filters[name]
      end

      # if we couldn't find the filter, rebuild the list and try
      # again
      @@filters = FilterRegistry.find_filters

      if @@filters.has_key? name
        return @@filters[name]
      else
        raise UnknownFilter.new(name)
      end
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
    attr_reader :filters

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

      nil
    end
  end


  # a composition streams the next filter on success
  class FilterComposition < AbstractCompoundFilter
    def streamLine(input)
      @filters.inject(input) do |line,filter|
        if line != nil
          filter.streamLine(line)
        else
          return nil
        end
      end
    end
  end


  # the and filter streams the original if all component filters stream
  class AndFilter < AbstractCompoundFilter
    def streamLine(line)
      @filters.each do |filter|
        if !filter.streamLine(line)
          return nil
        end
      end

      line
    end
  end


  # the or filter streams the original if any component filter streams
  class OrFilter < AbstractCompoundFilter
    def streamLine(line)
      @filters.each do |filter|
        if filter and filter.streamLine(line)
          return line
        end
      end

      return nil
    end
  end


  # the not filter streams the original if none of the component filters stream
  class NotFilter < AbstractCompoundFilter
    def streamLine(line)
      @filters.each do |filter|
        if filter.streamLine(line)
          return
        end
      end

      return line
    end
  end

  class ContainsFilter < AbstractFilter
    def initialize(*keys)
      @keys = keys
    end

    def streamLine(line)
      @keys.each do |key|
        if key.instance_of? Regexp and line[key]
          return line
        elsif key.instance_of? String and line.downcase.include? key.downcase
          return line
        end
      end

      nil
    end
  end

  class ReplaceFilter < AbstractFilter
    def initialize(regexp)
      @regexp = regexp
    end

    def streamLine(line)
      # why fold when you can iterate
      final = line
      @regexp.each_pair do |patt,val|
        final.gsub!(patt,val)
      end
      final
    end
  end


  # the sink filter never streams
  class SinkFilter < AbstractFilter
    def streamLine(line)
      nil
    end
  end

  # the stop filter stops all processing of this stream-line
  class StreamLineStop < Exception; end
  class StopFilter < AbstractFilter
    def streamLine(line)
      raise StreamLineStop
    end
  end

  # the pass through filter always streams
  class PassThroughFilter < AbstractFilter
    def streamLine(line)
      line
    end
  end




  #
  # Stream Mutators
  #

  class SampleFilter < AbstractFilter
    def initialize(params)
      @rate = params.to_i
      @count = 0
    end

    def streamLine(line)
      res = if @count % @rate == 0
        line
      else
        ""
      end

      @count += 1
      res
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
