module RbSDL2
  class Window
    module State
      def always_on_top=(bool)
        ::SDL.SetWindowAlwaysOnTop(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def bordered=(bool)
        ::SDL.SetWindowBordered(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def current! = ::SDL.RaiseWindow(self); self

      def fullscreen
        err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN)
        raise RbSDL2Error if err < 0
        self
      end

      def fullscreen_desktop
        err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN_DESKTOP)
        raise RbSDL2Error if err < 0
        self
      end

      def grab=(bool)
        ::SDL.SetWindowGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def grabbed? = ::SDL.GetWindowGrab(self) == ::SDL::TRUE

      def grabbed_keyboard? = ::SDL.GetWindowKeyboardGrab(self) == ::SDL::TRUE

      def grabbed_mouse? = ::SDL.GetWindowMouseGrab(self) == ::SDL::TRUE

      def hide = ::SDL.HideWindow(self); self

      def keyboard_grab=(bool)
        ::SDL.SetWindowKeyboardGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def maximize = ::SDL.MaximizeWindow(self); self

      def minimize = ::SDL.MinimizeWindow(self); self

      def mouse_grab=(bool)
        ::SDL.SetWindowMouseGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def resizable=(bool)
        ::SDL.SetWindowResizable(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def restore = ::SDL.RestoreWindow(self); self

      def show = ::SDL.ShowWindow(self); self

      def windowed
        err = ::SDL.SetWindowFullscreen(self, 0)
        raise RbSDL2Error if err < 0
        self
      end
    end
  end
end
