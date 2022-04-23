module RbSDL2
  # SDL のメモリーアロケーターで確保されたメモリー領域を表すクラスです。
  # SDL 関数の戻り値がポインターで Ruby 側でメモリー開放が必要な時（例えば char ポインター）に使用します。
  class SDLPointer < ::FFI::AutoPointer
    class << self
      def malloc(size)
        ptr = ::SDL.calloc(1, size)
        raise NoMemoryError if ptr.null?
        new(ptr)
      end

      def from_string(s)
        sdl = SDL.str_to_sdl(s)
        malloc(sdl.bytesize + 1).write_string(sdl)
      end

      def release(ptr) = ::SDL.free(ptr)
    end

    def to_s = SDL.ptr_to_str(self)
  end
end
