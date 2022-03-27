module RbSDL2
  module CPUInfo
    class << self
      def cpu_cache_line_size = ::SDL.GetCPUCacheLineSize

      def cpu_count = ::SDL.GetCPUCount

      # CPU 拡張命令があるか問い合わせます。 問い合わせできる CPU 拡張命令は
      #   :rdtsc : RDTSC 命令(x86)
      #   :altivec : AltiVec 拡張命令セット(Power)
      #   :mmx : MMX 拡張命令セット(x86)
      #   :amd3dnow : 3DNow! 拡張命令セット(AMD x86)
      #   :sse, :sse2, :sse3, :sse41, :sse42, :avx, :avx2, :avx5512f :
      #     Streaming SIMD 拡張命令セット(x86)
      #   :armsimd : ARMSIMD 拡張命令セット(Arm)
      #   :neon : Neon 拡張命令セット(Arm)
      # です。
      def cpu_extension?(sym)
        ::SDL::TRUE == case sym
                       when :rdtsc then ::SDL.HasRDTSC
                       when :altivec then ::SDL.HasAltiVec
                       when :mmx then ::SDL.HasMMX
                       when :amd3dnow then ::SDL.Has3DNow
                       when :sse then ::SDL.HasSSE
                       when :sse2 then ::SDL.HasSSE2
                       when :sse3 then ::SDL.HasSSE3
                       when :sse41 then ::SDL.HasSSE41
                       when :sse42 then ::SDL.HasSSE42
                       when :avx then ::SDL.HasAVX
                       when :avx2 then ::SDL.HasAVX2
                       when :avx512f then ::SDL.HasAVX512F
                       when :armsimd then ::SDL.HasARMSIMD
                       when :neon then ::SDL.HasNEON
                       else
                         raise ArgumentError, "Invalid cpu extension name(#{sym})"
                       end
      end

      # システムRAMのサイズを戻します。単位はメガバイトです.
      def system_ram = ::SDL.GetSystemRAM
    end
  end
end
