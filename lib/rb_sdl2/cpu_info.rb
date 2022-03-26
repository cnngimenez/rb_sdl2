module RbSDL2
  module CPUInfo
    class << self
      def cpu_count = ::SDL.GetCPUCount

      def cpu_cache_line_size = ::SDL.GetCPUCacheLineSize

      def system_ram = ::SDL.GetSystemRAM

      def rdtsc? = ::SDL.HasRDTSC == ::SDL::TRUE

      def altivec? = ::SDL.HasAltiVec == ::SDL::TRUE

      def mmx? = ::SDL.HasMMX == ::SDL::TRUE

      def _3dnow? = ::SDL.Has3DNow == ::SDL::TRUE

      def sse? = ::SDL.HasSSE == ::SDL::TRUE

      def sse2? = ::SDL.HasSSE2 == ::SDL::TRUE

      def sse3? = ::SDL.HasSSE3 == ::SDL::TRUE

      def sse41? = ::SDL.HasSSE41 == ::SDL::TRUE

      def sse42? = ::SDL.HasSSE42 == ::SDL::TRUE

      def avx? = ::SDL.HasAVX == ::SDL::TRUE

      def avx2? = ::SDL.HasAVX2 == ::SDL::TRUE

      def avx512f = ::SDL.HasAVX512F == ::SDL::TRUE

      def armsimd? = ::SDL.HasARMSIMD == ::SDL::TRUE

      def neon? = ::SDL.HasNEON == ::SDL::TRUE
    end
  end
end
