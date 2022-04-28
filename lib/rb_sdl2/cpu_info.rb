module RbSDL2
  module CPUInfo
    class << self
      # Power CPU の AltiVec 拡張命令セット
      def altivec? = ::SDL.HasAltiVec == ::SDL::TRUE

      # AMD x86 CPU の 3DNow! 拡張命令セット
      def amd3dnow? = ::SDL.Has3DNow == ::SDL::TRUE

      # Arm CPU の SIMD 命令セット
      def armsimd? = ::SDL.HasARMSIMD == ::SDL::TRUE

      # x86 CPU の AVX 命令セット
      def avx = ::SDL.HasAVX == ::SDL::TRUE

      # x86 CPU の AVX2 命令セット
      def avx2 = ::SDL.HasAVX2 == ::SDL::TRUE

      # x86 CPU の AVX-512F 命令セット
      def avx512f? = ::SDL.HasAVX512F == ::SDL::TRUE

      # CPU の L1 キャッシュラインサイズ（Byte）
      def cpu_cache_line_size = ::SDL.GetCPUCacheLineSize

      # 論理 CPU コアの総数
      def cpu_count = ::SDL.GetCPUCount

      # x86 CPU の MMX 命令セット
      def mmx? = ::SDL.HasMMX == ::SDL::TRUE

      # Arm CPU の NEON 命令セット
      def neon? = ::SDL.HasNEON == ::SDL::TRUE

      # x86 CPU の RDTSC 命令
      def rdtsc? = ::SDL.HasRDTSC == ::SDL::TRUE

      # x86 CPU の SSE 命令セット
      def sse? = ::SDL.HasSSE == ::SDL::TRUE

      # x86 CPU の SSE2 命令セット
      def sse2 = ::SDL.HasSSE2 == ::SDL::TRUE

      # x86 CPU の SSE3 命令セット
      def sse3 = ::SDL.HasSSE3 == ::SDL::TRUE

      # x86 CPU の SSE4.1 命令セット
      def sse41? = ::SDL.HasSSE41 == ::SDL::TRUE

      # x86 CPU の SSE4.2 命令セット
      def sse42? = ::SDL.HasSSE42 == ::SDL::TRUE

      # システム RAM のサイズ（MB）
      def system_ram = ::SDL.GetSystemRAM
    end
  end
end
