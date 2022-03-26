module RbSDL2
  module ScreenSaver
    class << self
      def enable = ::SDL.EnableScreenSaver

      def enabled? = ::SDL.IsScreenSaverEnabled == ::SDL::TRUE

      def disable = ::SDL.DisableScreenSaver
    end
  end
end
