
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

    def send(name, *args)

    end
  end
end