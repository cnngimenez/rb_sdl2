module RbSDL2
  module Mouse
    require_relative 'mouse_class'

    class GlobalMouse < MouseClass
      def initialize
        @_x = ::FFI::MemoryPointer.new(:int)
        @_y = ::FFI::MemoryPointer.new(:int)
        super
      end

      def position=(x_y)
        err = ::SDL.WarpMouseGlobal(*x_y)
        raise RbSDL2Error if err < 0
        super
      end

      def update
        self.button, self.x, self.y =
          ::SDL.GetGlobalMouseState(@_x, @_y), @_x.read_int, @_y.read_int
        self
      end
    end
  end
end
