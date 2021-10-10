module RbSDL2
  module Mouse
    class << self
      def capture=(bool)
        err = ::SDL2.SDL_CaptureMouse(bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
        raise RbSDL2Error if err < 0
      end

      def relative=(bool)
        err = ::SDL2.SDL_SetRelativeMouseMode(bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
        raise RbSDL2Error if err < 0
      end

      def relative? = ::SDL2.SDL_GetRelativeMouseMode == ::SDL2::SDL_TRUE
    end

    require 'forwardable'
    extend SingleForwardable

    class << self
      require_relative 'mouse/global_mouse'

      def global_mouse = GlobalMouse.instance
    end

    def_single_delegator "global_mouse.update", :position, :global_position
    def_single_delegator "global_mouse.update", :position=, :global_position=
    def_single_delegator "global_mouse.update", :x, :global_x
    def_single_delegator "global_mouse.update", :y, :global_y

    class << self
      require_relative 'mouse/mouse_wheel'

      def mouse_wheel = MouseWheel.instance
    end

    def_single_delegator "mouse_wheel.update", :position, :wheel_position
    def_single_delegator "Mouse::MouseWheel", :wheel=
    def_single_delegator "mouse_wheel.update", :x, :wheel_x
    def_single_delegator "mouse_wheel.update", :y, :wheel_y

    class << self
      require_relative 'mouse/relative_mouse'

      def relative_mouse = RelativeMouse.instance

      def relative_position=(rx_ry)
        rx, ry = rx_ry
        px, py = position
        self.position = [px + rx, py + ry]
      end
    end

    def_single_delegator "relative_mouse.update", :position, :relative_position
    def_single_delegator "relative_mouse.update", :x, :relative_x
    def_single_delegator "relative_mouse.update", :y, :relative_y

    class << self
      require_relative 'mouse/window_mouse'

      def window_mouse = WindowMouse.instance
    end

    def_single_delegator "window_mouse.update", :button

    require_relative 'mouse/mouse_button'
    extend MouseButton

    def_single_delegator "window_mouse.update", :position
    def_single_delegator "window_mouse.update", :position=
    def_single_delegator "window_mouse.update", :x
    def_single_delegator "window_mouse.update", :y
  end
end
