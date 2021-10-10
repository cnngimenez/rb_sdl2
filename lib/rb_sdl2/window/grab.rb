module RbSDL2
  class Window
    module Grab
      def grab=(bool)
        ::SDL2.SDL_SetWindowGrab(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
      end

      def grabbed? = ::SDL2.SDL_GetWindowGrab(self) == ::SDL2::SDL_TRUE

      def grabbed_keyboard? = ::SDL2.SDL_GetWindowKeyboardGrab(self) == ::SDL2::SDL_TRUE

      def grabbed_mouse? = ::SDL2.SDL_GetWindowMouseGrab(self) == ::SDL2::SDL_TRUE

      def keyboard_grab=(bool)
        ::SDL2.SDL_SetWindowKeyboardGrab(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
      end

      def mouse_grab=(bool)
        ::SDL2.SDL_SetWindowMouseGrab(self, bool ? ::SDL2::SDL_TRUE : ::SDL2::SDL_FALSE)
      end
    end
  end
end
