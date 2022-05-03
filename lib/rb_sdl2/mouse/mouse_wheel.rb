module RbSDL2
  module Mouse
    class MouseWheel
      def initialize(window = nil)
        @wheel_x = @wheel_y = @x = @y = 0
        window_id = window&.window_id
        proc = -> (event) do
          if event.mouse_wheel? && window_id && event[:windowID] == window_id
            a = event[:direction] == ::SDL::MOUSEWHEEL_FLIPPED ? -1 : 1
            @x += event[:x] * a
            @y += event[:y] * a
          end
        end
        @watch = EventFilter.new(proc)
      end

      def update
        @wheel_x, @wheel_y = @x, @y
        @x = @y = 0
        self
      end

      def wheel=(bool)
        if bool
          EventFilter.define_watch(@watch)
        else
          EventFilter.undefine_watch(@watch)
        end
        @wheel_x = @wheel_y = @x = @y = 0
      end

      def wheel_position = [@wheel_x, @wheel_y]

      attr_reader :wheel_x, :wheel_y, :window_id
    end
  end
end
