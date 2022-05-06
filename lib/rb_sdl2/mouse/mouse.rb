module RbSDL2
  module Mouse
    class << self
      def capture=(bool)
        err = ::SDL.CaptureMouse(bool ? ::SDL::TRUE : ::SDL::FALSE)
        raise RbSDL2Error if err < 0
      end

      def relative=(bool)
        err = ::SDL.SetRelativeMouseMode(bool ? ::SDL::TRUE : ::SDL::FALSE)
        raise RbSDL2Error if err < 0
      end

      def relative? = ::SDL.GetRelativeMouseMode == ::SDL::TRUE
    end

    require_relative 'global_mouse'
    require_relative 'mouse_wheel'
    require_relative 'relative_mouse'

    @x, @y = ::FFI::MemoryPointer.new(:int), ::FFI::MemoryPointer.new(:int)

    class << self
      def global_mouse = GlobalMouse.new.update

      def relative_mouse = RelativeMouse.instance

      def button = ::SDL.GetMouseState(nil, nil)

      require_relative 'mouse_button'
      include MouseButton

      def position
        ::SDL.GetMouseState(@x, @y)
        [@x.read_int, @y.read_int]
      end

      def position=(x_y)
        ::SDL.WarpMouseInWindow(nil, *x_y)
      end

      def x
        ::SDL.GetMouseState(@x, nil)
        @x.read_int
      end

      def y
        ::SDL.GetMouseState(nil, @y)
        @y.read_int
      end

      def wheel=(bool)
        if bool
          @wheel ||= MouseWheel.new.tap { |obj| obj.wheel = true }
        else
          @wheel.wheel = false
          @wheel = nil
        end
      end

      def wheel = @wheel&.update.wheel_y
    end
  end
end
