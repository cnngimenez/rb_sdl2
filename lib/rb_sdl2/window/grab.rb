module RbSDL2
  class Window
    module Grab
      def grab=(bool)
        ::SDL.SetWindowGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def grabbed? = ::SDL.GetWindowGrab(self) == ::SDL::TRUE

      def grabbed_keyboard? = ::SDL.GetWindowKeyboardGrab(self) == ::SDL::TRUE

      def grabbed_mouse? = ::SDL.GetWindowMouseGrab(self) == ::SDL::TRUE

      def keyboard_grab=(bool)
        ::SDL.SetWindowKeyboardGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def mouse_grab=(bool)
        ::SDL.SetWindowMouseGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end
    end
  end
end
