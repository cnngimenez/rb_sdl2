module RbSDL2
  module Video
    class << self
      def init(driver = nil)
        raise RbSDL2Error if ::SDL2.SDL_VideoInit(driver) < 0
      end

      def current
        ptr = ::SDL2.SDL_GetCurrentVideoDriver
        raise RbSDL2Error if ptr.null?
        ptr.read_string
      end

      def drivers
        ::SDL2.SDL_GetNumVideoDrivers.times.map do |num|
          ptr = ::SDL2.SDL_GetVideoDriver(num)
          raise RbSDL2Error if ptr.null?
          ptr.read_string
        end
      end

      def quit = ::SDL2.SDL_VideoQuit
    end
  end
end
