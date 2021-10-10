module RbSDL2
  module CPUInfo
    class << self
      def cpu_count = ::SDL2.SDL_GetCPUCount

      def cpu_cache_line_size = ::SDL2.SDL_GetCPUCacheLineSize

      def system_ram = ::SDL2.SDL_GetSystemRAM

      def rdtsc? = ::SDL2.SDL_HasRDTSC == ::SDL2::SDL_TRUE

      def altivec? = ::SDL2.SDL_HasAltiVec == ::SDL2::SDL_TRUE

      def mmx? = ::SDL2.SDL_HasMMX == ::SDL2::SDL_TRUE

      def _3dnow? = ::SDL2.SDL_Has3DNow == ::SDL2::SDL_TRUE

      def sse? = ::SDL2.SDL_HasSSE == ::SDL2::SDL_TRUE

      def sse2? = ::SDL2.SDL_HasSSE2 == ::SDL2::SDL_TRUE

      def sse3? = ::SDL2.SDL_HasSSE3 == ::SDL2::SDL_TRUE

      def sse41? = ::SDL2.SDL_HasSSE41 == ::SDL2::SDL_TRUE

      def sse42? = ::SDL2.SDL_HasSSE42 == ::SDL2::SDL_TRUE

      def avx? = ::SDL2.SDL_HasAVX == ::SDL2::SDL_TRUE

      def avx2? = ::SDL2.SDL_HasAVX2 == ::SDL2::SDL_TRUE

      def avx512f = ::SDL2.SDL_HasAVX512F == ::SDL2::SDL_TRUE

      def armsimd? = ::SDL2.SDL_HasARMSIMD == ::SDL2::SDL_TRUE

      def neon? = ::SDL2.SDL_HasNEON == ::SDL2::SDL_TRUE
    end
  end
end
