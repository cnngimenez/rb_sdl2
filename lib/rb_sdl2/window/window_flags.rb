module RbSDL2
  class Window
    module WindowFlags
      class << self
        def to_num(allow_high_dpi: false, always_on_top: false, borderless: false, foreign: false,
                   fullscreen: false, fullscreen_desktop: false, hidden: false, input_focus: false,
                   input_grabbed: false, maximized: false, minimized: false, mouse_capture: false,
                   mouse_focus: false, opengl: false, popup_menu: false, resizable: false,
                   shown: false, skip_taskbar: false, tooltip: false, utility: false, vulkan: false)
          0 |
            (allow_high_dpi ? ::SDL2::SDL_WINDOW_ALLOW_HIGHDPI : 0) |
            (always_on_top ? ::SDL2::SDL_WINDOW_ALWAYS_ON_TOP : 0) |
            (borderless ? ::SDL2::SDL_WINDOW_BORDERLESS : 0) |
            (foreign ? ::SDL2::SDL_WINDOW_FOREIGN : 0) |
            (fullscreen ? ::SDL2::SDL_WINDOW_FULLSCREEN : 0) |
            (fullscreen_desktop ? ::SDL2::SDL_WINDOW_FULLSCREEN_DESKTOP : 0) |
            (hidden ? ::SDL2::SDL_WINDOW_HIDDEN : 0) |
            (input_focus ? ::SDL2::SDL_WINDOW_INPUT_FOCUS : 0) |
            (input_grabbed ? ::SDL2::SDL_WINDOW_INPUT_GRABBED : 0) |
            (maximized ? ::SDL2::SDL_WINDOW_MAXIMIZED : 0) |
            (minimized ? ::SDL2::SDL_WINDOW_MINIMIZED : 0) |
            (mouse_capture ? ::SDL2::SDL_WINDOW_MOUSE_CAPTURE : 0) |
            (mouse_focus ? ::SDL2::SDL_WINDOW_MOUSE_FOCUS : 0) |
            (opengl ? ::SDL2::SDL_WINDOW_OPENGL : 0)  |
            (popup_menu ? ::SDL2::SDL_WINDOW_POPUP_MENU : 0) |
            (resizable ? ::SDL2::SDL_WINDOW_RESIZABLE : 0) |
            (shown ? ::SDL2::SDL_WINDOW_SHOWN : 0) |
            (skip_taskbar ? ::SDL2::SDL_WINDOW_SKIP_TASKBAR : 0) |
            (tooltip ? ::SDL2::SDL_WINDOW_TOOLTIP : 0) |
            (utility ? ::SDL2::SDL_WINDOW_UTILITY : 0) |
            (vulkan ? ::SDL2::SDL_WINDOW_VULKAN : 0)
        end
      end

      def allow_high_dpi? = ::SDL2::SDL_WINDOW_ALLOW_HIGHDPI & flags != 0

      def always_on_top? = ::SDL2::SDL_WINDOW_ALWAYS_ON_TOP & flags != 0

      def borderless? = ::SDL2::SDL_WINDOW_BORDERLESS & flags != 0

      def foreign? = ::SDL2::SDL_WINDOW_FOREIGN & flags != 0

      def fullscreen? = ::SDL2::SDL_WINDOW_FULLSCREEN & flags != 0

      def fullscreen_desktop? = ::SDL2::SDL_WINDOW_FULLSCREEN_DESKTOP & flags != 0

      def hidden? = ::SDL2::SDL_WINDOW_HIDDEN & flags != 0

      def input_focused? = ::SDL2::SDL_WINDOW_INPUT_FOCUS & flags != 0

      def input_grabbed? = ::SDL2::SDL_WINDOW_INPUT_GRABBED & flags != 0

      def maximized? = ::SDL2::SDL_WINDOW_MAXIMIZED & flags != 0

      def minimized? = ::SDL2::SDL_WINDOW_MINIMIZED & flags != 0

      def mouse_captured? = ::SDL2::SDL_WINDOW_MOUSE_CAPTURE & flags != 0

      def mouse_focused? = ::SDL2::SDL_WINDOW_MOUSE_FOCUS & flags != 0

      def opengl? = ::SDL2::SDL_WINDOW_OPENGL & flags != 0

      def popup_menu? = ::SDL2::SDL_WINDOW_POPUP_MENU & flags != 0

      def resizable? = ::SDL2::SDL_WINDOW_RESIZABLE & flags != 0

      def skip_taskbar? = ::SDL2::SDL_WINDOW_SKIP_TASKBAR & flags != 0

      def shown? = ::SDL2::SDL_WINDOW_SHOWN & flags != 0

      def tooltip? = ::SDL2::SDL_WINDOW_TOOLTIP & flags != 0

      def utility? = ::SDL2::SDL_WINDOW_UTILITY & flags != 0

      def vulkan? = ::SDL2::SDL_WINDOW_VULKAN & flags != 0
    end
  end
end
