module RbSDL2
  module Mouse
    require_relative 'mouse_class'

    class WindowMouse < MouseClass
      def position=(*x_y)
        ptr = ::SDL.GetMouseFocus
        ::SDL.WarpMouseInWindow(ptr, *x_y) unless ptr.null?
      end

      def update
        self.button = ::SDL.GetMouseState(x_ptr, y_ptr)
        self
      end
    end
  end
end
