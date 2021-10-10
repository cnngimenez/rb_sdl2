module RbSDL2
  class Audio
    class AudioBuffer
      class AudioBufferPointer < ::FFI::AutoPointer
        def self.release(ptr) = ::SDL2::SDL_FreeWAV(ptr)
      end

      class << self
        require_relative '../rw_ops'

        def load(file) = RWOps.new(file, "rb") { |rw| load_rw(rw) }

        require_relative 'audio_spec'

        # load_rw は与えられたオブジェクトをオートクローズしません。
        def load_rw(rw)
          spec = AudioSpec.new
          buf = ::FFI::MemoryPointer.new(:pointer)
          len = ::FFI::MemoryPointer.new(:uint32)
          err = ::SDL2::SDL_LoadWAV_RW(rw, 0, spec, buf, len)
          raise RbSDL2Error if err.null?
          new(AudioBufferPointer.new(buf.read_pointer), len.read_uint32, spec)
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

      require 'forwardable'
      extend Forwardable
      def_delegators :spec, *%i(channels format frequency)

      require_relative 'audio_format'
      include AudioFormat

      def to_ptr = @ptr

      def to_str = @ptr.read_bytes(size)
    end
  end
end
