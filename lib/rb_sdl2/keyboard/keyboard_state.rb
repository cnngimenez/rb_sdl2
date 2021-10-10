module RbSDL2
  class KeyboardState
    require 'singleton'
    include Singleton

    def initialize
      num_keys = ::FFI::MemoryPointer.new(:int)
      # SDL_GetKeyboardState が戻すポインターは SDL がロードされた時点でメモリー確保している。
      # 戻されたポインターは不変と考えてよい。
      # SDL_GetKeyboardState は SDL_init より前に呼ぶことができる。
      # SDL_GetKeyboardState は引数に NULL ポインターを与えた場合にエラーを戻す。
      @ptr = ::SDL2.SDL_GetKeyboardState(num_keys)
      raise RbSDL2Error if @ptr.null?
      @size = num_keys.read_int
    end

    # nth のキーが押されている場合、nth を戻す。
    # nth のキーが押されていない、nth が範囲外の場合は nil を戻す。
    # 真偽値を戻すようにしなかったのは、このメソッドを応用したコードを書く際に index 情報を不要にするためである。
    # 戻り値が nil | obj なのは Numeric#nonzero? を参考にした。（この戻り値は Ruby において真偽値と同等である）
    def [](nth)
      if 0 <= nth && nth < size && @ptr[nth].read_uint8 == ::SDL2::SDL_PRESSED
        nth
      end
    end

    def each = block_given? ? size.times { |i| yield(self[i]) } : to_enum

    attr_reader :size
    alias length size

    def to_str = @ptr.read_bytes(size)
  end
end
