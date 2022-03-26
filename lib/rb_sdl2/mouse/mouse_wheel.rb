module RbSDL2
  module Mouse
    class MouseWheel
      @timestamp = @x = @y = 0
      @mutex = Mutex.new

      MOUSE_WHEEL_EVENT_WATCH = -> (event, _) {
        if event.mouse_wheel?
          a = event[:direction] == ::SDL::MOUSEWHEEL_FLIPPED ? -1 : 1
          @timestamp = event[:timestamp]
          @x = event[:x] * a
          @y = event[:y] * a
        end
      }

      class << self
        attr_reader :timestamp, :x, :y

        require_relative '../event'

        def wheel=(bool)
          @mutex.synchronize do
            if bool
              Event.add_watch_callback(MOUSE_WHEEL_EVENT_WATCH)
            else
              Event.remove_watch_callback(MOUSE_WHEEL_EVENT_WATCH)
            end
          end
        end
      end

      require 'singleton'
      include Singleton

      def initialize
        @timestamp = @x = @y = 0
      end

      def position = [x, y]

      def update
        if @timestamp != MouseWheel.timestamp
          @x, @y, @timestamp = MouseWheel.x, MouseWheel.y, MouseWheel.timestamp
        else
          @x, @y = 0, 0
        end
        self
      end

      attr_reader :x, :y
    end
  end
end
