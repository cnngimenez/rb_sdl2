module RbSDL2
  module Video
    class << self
      def init(driver = nil)
        raise RbSDL2Error if ::SDL.VideoInit(driver) < 0
      end

      def current
        ptr = ::SDL.GetCurrentVideoDriver
        raise RbSDL2Error if ptr.null?
        ptr.read_string
      end

      def drivers
        ::SDL.GetNumVideoDrivers.times.map do |num|
          ptr = ::SDL.GetVideoDriver(num)
          raise RbSDL2Error if ptr.null?
          ptr.read_string
        end
      end

      def quit = ::SDL.VideoQuit
    end
  end
end
