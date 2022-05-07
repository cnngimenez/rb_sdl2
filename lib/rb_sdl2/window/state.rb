module RbSDL2
  class Window
    SDL_WINDOW_FULLSCREEN         = 0x00000001
    SDL_WINDOW_OPENGL             = 0x00000002
    SDL_WINDOW_SHOWN              = 0x00000004
    SDL_WINDOW_HIDDEN             = 0x00000008
    SDL_WINDOW_BORDERLESS         = 0x00000010
    SDL_WINDOW_RESIZABLE          = 0x00000020
    SDL_WINDOW_MINIMIZED          = 0x00000040
    SDL_WINDOW_MAXIMIZED          = 0x00000080
    SDL_WINDOW_MOUSE_GRABBED      = 0x00000100
    SDL_WINDOW_INPUT_FOCUS        = 0x00000200
    SDL_WINDOW_MOUSE_FOCUS        = 0x00000400
    SDL_WINDOW_FULLSCREEN_DESKTOP = SDL_WINDOW_FULLSCREEN | 0x00001000
    SDL_WINDOW_FOREIGN            = 0x00000800
    SDL_WINDOW_ALLOW_HIGHDPI      = 0x00002000
    SDL_WINDOW_MOUSE_CAPTURE      = 0x00004000
    SDL_WINDOW_ALWAYS_ON_TOP      = 0x00008000
    SDL_WINDOW_SKIP_TASKBAR       = 0x00010000
    SDL_WINDOW_UTILITY            = 0x00020000
    SDL_WINDOW_TOOLTIP            = 0x00040000
    SDL_WINDOW_POPUP_MENU         = 0x00080000
    SDL_WINDOW_KEYBOARD_GRABBED   = 0x00100000
    SDL_WINDOW_VULKAN             = 0x10000000
    SDL_WINDOW_METAL              = 0x20000000

    SDL_WINDOW_INPUT_GRABBED = SDL_WINDOW_MOUSE_GRABBED

    module State
      class << self
        def to_flags(allow_high_dpi: false, always_on_top: false, borderless: false, foreign: false,
                     fullscreen: false, fullscreen_desktop: false, hidden: false, input_focus: false,
                     input_grabbed: false, keyboard_grabbed: false, maximized: false, metal: false,
                     minimized: false, mouse_capture: false, mouse_focus: false, mouse_grabbed: false,
                     opengl: false, popup_menu: false, resizable: false, shown: false,
                     skip_taskbar: false, tooltip: false, utility: false, vulkan: false)
          0 |
            (allow_high_dpi ? SDL_WINDOW_ALLOW_HIGHDPI : 0) |
            (always_on_top ? SDL_WINDOW_ALWAYS_ON_TOP : 0) |
            (borderless ? SDL_WINDOW_BORDERLESS : 0) |
            (foreign ? SDL_WINDOW_FOREIGN : 0) |
            (fullscreen ? SDL_WINDOW_FULLSCREEN : 0) |
            (fullscreen_desktop ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0) |
            (hidden ? SDL_WINDOW_HIDDEN : 0) |
            (input_focus ? SDL_WINDOW_INPUT_FOCUS : 0) |
            (input_grabbed ? SDL_WINDOW_INPUT_GRABBED : 0) |
            (keyboard_grabbed ? SDL_WINDOW_KEYBOARD_GRABBED : 0) |
            (maximized ? SDL_WINDOW_MAXIMIZED : 0) |
            (metal ? SDL_WINDOW_METAL : 0) |
            (minimized ? SDL_WINDOW_MINIMIZED : 0) |
            (mouse_capture ? SDL_WINDOW_MOUSE_CAPTURE : 0) |
            (mouse_focus ? SDL_WINDOW_MOUSE_FOCUS : 0) |
            (mouse_grabbed ? SDL_WINDOW_MOUSE_GRABBED : 0) |
            (opengl ? SDL_WINDOW_OPENGL : 0)  |
            (popup_menu ? SDL_WINDOW_POPUP_MENU : 0) |
            (resizable ? SDL_WINDOW_RESIZABLE : 0) |
            (shown ? SDL_WINDOW_SHOWN : 0) |
            (skip_taskbar ? SDL_WINDOW_SKIP_TASKBAR : 0) |
            (tooltip ? SDL_WINDOW_TOOLTIP : 0) |
            (utility ? SDL_WINDOW_UTILITY : 0) |
            (vulkan ? SDL_WINDOW_VULKAN : 0)
        end
      end

      def allow_high_dpi? = flags?(SDL_WINDOW_ALLOW_HIGHDPI)

      def always_on_top=(bool)
        ::SDL.SetWindowAlwaysOnTop(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def always_on_top? = flags?(SDL_WINDOW_ALWAYS_ON_TOP)

      def bordered=(bool)
        ::SDL.SetWindowBordered(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def borderless? = flags?(SDL_WINDOW_BORDERLESS)

      def current! = ::SDL.RaiseWindow(self); self

      def flags = ::SDL.GetWindowFlags(self)

      def flags?(num) = flags & num != 0

      def foreign? = flags?(SDL_WINDOW_FOREIGN)

      def fullscreen
        err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN)
        raise RbSDL2Error if err < 0
        self
      end

      def fullscreen? = flags?(SDL_WINDOW_FULLSCREEN)

      def fullscreen_desktop
        err = ::SDL.SetWindowFullscreen(self, ::SDL::WINDOW_FULLSCREEN_DESKTOP)
        raise RbSDL2Error if err < 0
        self
      end

      def fullscreen_desktop? = flags?(SDL_WINDOW_FULLSCREEN_DESKTOP)

      def grab=(bool)
        ::SDL.SetWindowGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def grabbed? = ::SDL.GetWindowGrab(self) == ::SDL::TRUE

      def grabbed_keyboard? = ::SDL.GetWindowKeyboardGrab(self) == ::SDL::TRUE

      def grabbed_mouse? = ::SDL.GetWindowMouseGrab(self) == ::SDL::TRUE

      def hide = ::SDL.HideWindow(self); self

      def hidden? = flags?(SDL_WINDOW_HIDDEN)

      def input_focused? = flags?(SDL_WINDOW_INPUT_FOCUS)

      def input_grabbed? = flags?(SDL_WINDOW_INPUT_GRABBED)

      def keyboard_grab=(bool)
        ::SDL.SetWindowKeyboardGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def keyboard_grabbed? = flags?(SDL_WINDOW_KEYBOARD_GRABBED)

      def maximize = ::SDL.MaximizeWindow(self); self

      def maximized? = flags?(SDL_WINDOW_MAXIMIZED)

      def metal? = flags?(SDL_WINDOW_METAL)

      def minimize = ::SDL.MinimizeWindow(self); self

      def minimized? = flags?(SDL_WINDOW_MINIMIZED)

      def mouse_captured? = flags?(SDL_WINDOW_MOUSE_CAPTURE)

      def mouse_focused? = flags?(SDL_WINDOW_MOUSE_FOCUS)

      def mouse_grab=(bool)
        ::SDL.SetWindowMouseGrab(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def mouse_grabbed? = flags?(SDL_WINDOW_MOUSE_GRABBED)

      def opengl? = flags?(SDL_WINDOW_OPENGL)

      def popup_menu? = flags?(SDL_WINDOW_POPUP_MENU)

      def resizable=(bool)
        ::SDL.SetWindowResizable(self, bool ? ::SDL::TRUE : ::SDL::FALSE)
      end

      def resizable? = flags?(SDL_WINDOW_RESIZABLE)

      def restore = ::SDL.RestoreWindow(self); self

      def show = ::SDL.ShowWindow(self); self

      def shown? = flags?(SDL_WINDOW_SHOWN)

      def skip_taskbar? = flags?(SDL_WINDOW_SKIP_TASKBAR)

      def tooltip? = flags?(SDL_WINDOW_TOOLTIP)

      def utility? = flags?(SDL_WINDOW_UTILITY)

      def vulkan? = flags?(SDL_WINDOW_VULKAN)

      def windowed
        err = ::SDL.SetWindowFullscreen(self, 0)
        raise RbSDL2Error if err < 0
        self
      end
    end
  end
end
