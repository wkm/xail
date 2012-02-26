require 'curses'

module Xail
  class UI
    def width
      Curses.maxx
    end

    def height
      Curses.maxy
    end

    def init
      Curses.noecho
      Curses.init_screen

      yield
    ensure
      Curses.close_screen
    end
  end
end

