module RbSDL2
  class Audio
    class AudioBuffer
      class AudioBufferPointer < ::FFI::AutoPointer
        def self.release(ptr) = ::SDL::FreeWAV(ptr)
      end

      class << self
        require_relative 'audio_spec'

        def load(obj)
          RbSDL2.open_rw(obj) do |rw|
            spec = AudioSpec.new
            buf = ::FFI::MemoryPointer.new(:pointer)
            len = ::FFI::MemoryPointer.new(:uint32)
            err = ::SDL::LoadWAV_RW(rw, 0, spec, buf, len)
            raise RbSDL2Error if err.null?
            new(AudioBufferPointer.new(buf.read_pointer), len.read_uint32, spec)
          end
        end
      end

      def initialize(ptr, size, spec)
        @ptr = ptr
        @size = size
        @spec = spec
      end

      attr_reader :size
      alias length size

      attr_reader :spec

      require_relative 'audio_spec_reader'
      include AudioSpecReader

      def to_ptr = @ptr

      def to_str = @ptr.read_bytes(size)
    end
  end
end
