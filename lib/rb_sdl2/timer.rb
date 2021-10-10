module RbSDL2
  module Timer
    class << self
      def delay(ms)
        raise ArgumentError if ms < 0
        ::SDL2.SDL_Delay(ms)
      end

      def performance_frequency = ::SDL2.SDL_GetPerformanceFrequency

      def performance_count = ::SDL2.SDL_GetPerformanceCounter

      def realtime
        t = performance_count
        yield
        (performance_count - t).fdiv(performance_frequency)
      end

      def ticks = ::SDL2.SDL_GetTicks
    end
  end
end
