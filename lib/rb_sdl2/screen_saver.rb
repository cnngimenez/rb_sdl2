module RbSDL2
  module ScreenSaver
    class << self
      def enable = ::SDL2.SDL_EnableScreenSaver

      def enabled? = ::SDL2.SDL_IsScreenSaverEnabled == ::SDL2::SDL_TRUE

      def disable = ::SDL2.SDL_DisableScreenSaver
    end
  end
end
