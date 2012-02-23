
require 'xail/filter'

module Xail
  module DSL
    @filter = FilterCascade.new

    def stream(name, source = null)
      source ||= name
    end

    def group(name, &filters)

    end

    def rest(&filters)

    end

    def match(*keys)

    end

    def sample(count)

    end
  end
end